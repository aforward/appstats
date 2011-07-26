
module Appstats
  class Query

    @@parser_template = Appstats::Parser.new(:rules => ":operation :action :date on :host where :contexts group by :group_by")
    @@contexts_parser_template = Appstats::Parser.new(:rules => ":context", :repeating => true, :tokenize => "( ) and or || && = <= >= <> < > != like 'not like' in 'not in'")
    @@group_by_parser_template = Appstats::Parser.new(:rules => ":filter", :repeating => true, :tokenize => ",")

    @@nill_query = "select 0 from appstats_entries LIMIT 1"
    @@default = "1=1"
    attr_accessor :name, :query, :action, :host, :date_range, :query_to_sql, :contexts, :parsed_contexts, :group_by, :group_query_to_sql, :query_type

    def initialize(data = {})
      @name = data[:name]
      @query_type = data[:query_type]
      @result_type = data[:result_type] || "on_demand"
      self.query=(data[:query])
    end
    
    def query=(value)
      @query = value
      parse_query
      
      unless @query_type.nil?
        
        all_names = @query_type.split("::")
        if all_names.size == 1
          @custom_query = Object::const_get(@query_type).new  
        else
          @custom_query = eval(all_names[0...-1].join("::")).const_get(all_names.last).new
        end
        @custom_query.query = self
        @custom_query.process_query
      end
      
    end
    
    def find(job_frequency_if_not_available = 'once')
      result = Appstats.rails3? ? Appstats::Result.where("query = ? and is_latest = 1",@query).first : Appstats::Result.find(:first,:conditions => [ "query = ? and is_latest = 1",@query ]) 
      if result.nil?
        if job_frequency_if_not_available.nil?
          result = run
        else
          job_frequency_if_not_available = "once" if job_frequency_if_not_available == true
          existing = Appstats.rails3? ? Appstats::ResultJob.where("query = ? and (last_run_at is null or frequency <> 'once')",@query).first : Appstats::ResultJob.find(:first,:conditions => [ "query = ? and (last_run_at is null or frequency <> 'once')",@query ]) 
          if existing.nil?
            Appstats::ResultJob.create(:name => "Missing Query#find requested", :frequency => job_frequency_if_not_available, :query => @query, :query_type => @query_type)  
          end
        end
      end
      result
    end
    
    def run
      result = Appstats::Result.new(:name => @name, :result_type => @result_type, :query => @query, :query_to_sql => @query_to_sql, :action => @action, :host => @host, :from_date => @date_range.from_date, :to_date => @date_range.to_date, :contexts => @contexts, :query_type => @query_type)
      unless @group_by.empty?
        result.group_by = @group_by.join(", ")
        result.group_query_to_sql = @group_query_to_sql
      end

      result.group_by = @group_by.join(", ") unless @group_by.empty?
      
      data = run_query { |conn| conn.select_one(@query_to_sql)["num"].to_i }
      unless data.nil?
        result.count = data[:results]
        result.query_duration_in_seconds = data[:duration]
        result.db_username = data[:db_config][:username]
        result.db_name = data[:db_config][:database]
        result.db_host = data[:db_config][:host]
      end
      result.save

      if !@group_by.empty? && !result.count.nil?
        running_total = 0
        data = run_query { |conn| conn.select_all(@group_query_to_sql) }
        result.group_query_duration_in_seconds = data[:duration] unless data.nil?
        all_sub_results = data.nil? ? [] : data[:results]
        all_sub_results.each do |data|
          if data["context_key_filter"].nil? || data["num"].nil?
            Appstats.log(:error,"Missing context_key_filter, or num in #{data.inspect}")
            next 
          end

          if data["context_value_filter"].nil?
            Appstats.log(:error,"Missing context_value_filter, setting to empty string ''")
            data["context_value_filter"] = ""
          end
          
          keys = data["context_key_filter"].split(",")
          values = data["context_value_filter"].split(",")
          key_values = {} and keys.each_with_index { |k,i| key_values[k] = values[i] }
          current_count = data["num"].to_i
          ratio_of_total = current_count.to_f / result.count
          running_total += current_count
          sub_result = Appstats::SubResult.new(:context_filter => @group_by.collect { |k| key_values[k] }.join(", "), :count => current_count, :ratio_of_total => ratio_of_total)
          sub_result.result = result
          sub_result.save
        end
        
        if running_total < result.count
          remaining_total = result.count - running_total
          ratio_of_total = remaining_total.to_f / result.count
          sub_result = Appstats::SubResult.new(:context_filter => nil, :count => remaining_total, :ratio_of_total => ratio_of_total)
          sub_result.result = result
          sub_result.save
        end

        result.save
      end
      
      if @operation == "#!"
        if Appstats.rails3?
          Result.where("(query = ? or query = ?) and id <> ?",@query,@query.sub("#!","#"),result.id).delete_all
        else
          Result.delete_all(["(query = ? or query = ?) and id <> ?",@query,@query.sub("#!","#"),result.id])
        end
        result.save
      end
      
      result.reload
      result
    end
    
    def self.host_filter_to_sql(raw_input)
      return @@default if raw_input.nil?
      input = raw_input.strip
      m = raw_input.strip.match(/(^[^\s']*$)/)
      return @@default if m.nil?
      host = m[1]
      return @@default if host == '' or host.nil?
      "EXISTS (select * from appstats_log_collectors where appstats_entries.appstats_log_collector_id = appstats_log_collectors.id and host = '#{host}' )"
    end

    def contexts_filter_to_sql
      context_parser = @@contexts_parser_template.dup
      return @@default if @contexts.blank? || !context_parser.parse(@contexts)
      sql = "EXISTS (select * from appstats_contexts where appstats_entries.id = appstats_contexts.appstats_entry_id and ("
      
      status = :next
      comparator = "="
      context_parser.raw_results.each do |entry|
        if entry.kind_of?(String)
          sqlentry = Query.sqlize(entry)
          if Query.comparator?(entry) && status == :waiting_comparator
            comparator = Query.sqlize(entry)
            status = :waiting_operand
          else
            sql += ")" if status == :waiting_comparator
            sql += " #{sqlentry}"
            @parsed_contexts<< sqlentry
            status = :next
          end
          next
        end
        if status == :next
          status = :waiting_comparator
          @parsed_contexts<< { :context_key => entry[:context] }
          sql += " (context_key = #{Query.sqlquote(entry[:context])}"
        else
          status = :next
          @parsed_contexts.last[:context_value] = entry[:context]
          @parsed_contexts.last[:comparator] = comparator
          sql += " and context_value #{comparator} #{Query.sqlquote(entry[:context],comparator)})"
        end
      end
      sql += ")" if status == :waiting_comparator
      sql += "))"
      sql
    end
    
    def self.sqlize(input)
      return "and" if input == "&&"
      return "or" if input == "||"
      return "<>" if input == "!="
      input
    end
    
    def self.sqlquote(raw_input,comparator = '=')
      return "NULL" if raw_input.nil?
      if ["in","not in"].include?(comparator)
        return "(" + raw_input.split(",").collect { |x| sqlquote(x) }.join(",") + ")"
      else
        return "'#{sqlclean(raw_input)}'"  
      end
    end
    
    def self.sqlclean(raw_input)
      return raw_input if raw_input.blank?
      m = raw_input.match(/^['"](.*)['"]$/)
      input = m.nil? ? raw_input : m[1]
      input = input.gsub(/\\/, '\&\&').gsub(/'/, "''")
      input
    end
    
    def self.comparator?(raw_input)
      return false if raw_input.nil?
      comparators.include?(raw_input)
    end
    
    def self.comparators
      ["=","!=","<>",">","<",">=","<=","like","not like","in","not in"]
    end
    
    private
    
      def db_connection
        return Appstats.connection if @custom_query.nil?
        @backup_config =  ActiveRecord::Base.connection.instance_variable_get(:@config)
        custom_connection = @custom_query.db_connection
      end
    
      def restore_connection
        return if @backup_config.nil?
        ActiveRecord::Base.establish_connection @backup_config
        @backup_config = nil
      end
    
      def run_query
        begin
          timer = FriendlyTimer.new
          results = yield db_connection
          timer.stop
          db_config = Appstats.connection.instance_variable_get(:@config)
          restore_connection
          data = { :results => results, :db_config => db_config, :duration => timer.duration }
          return data
        rescue Exception => e
          restore_connection
          Appstats.log(:error,"Something bad occurred during Appstats::#{query_type}#run_query")
          Appstats.log(:error,e.message)
          return nil
        end
      end
    
    
      def normalize_action_name(action_name)
        action = Appstats.rails3? ? Appstats::Action.where("plural_name = ?",action_name).first : Appstats::Action.find(:first,:conditions => [ "plural_name = ?",action_name ]) 
        action.nil? ? action_name : action.name 
      end
      
      def parse_group_by(raw_input)
        group_parser = @@group_by_parser_template.dup
        return if (raw_input.blank? || !group_parser.parse(raw_input))
        group_parser.raw_results.each do |entry|
          next if entry.kind_of?(String)
          @group_by<< entry[:filter]
        end
      end
      
      def parse_contexts(raw_input)
        @contexts = raw_input
        context_parser = @@contexts_parser_template.dup
        return if (raw_input.blank? || !context_parser.parse(raw_input))
      end
      
      def parse_query
        reset_query
        return nil_query if @query.nil?
        current_query = fix_legacy_structures(@query)
        
        parser = @@parser_template.dup
        return nil_query unless parser.parse(current_query)
        
        @operation = parser.results[:operation]
        @action = normalize_action_name(parser.results[:action])
        @date_range = DateRange.parse(parser.results[:date])
        @host = parser.results[:host]
        parse_contexts(parser.results[:contexts])
        parse_group_by(parser.results[:group_by])
        
        if !@operation.nil? && @operation.starts_with?("#")
          @query_to_sql = "select count(*) as num from appstats_entries"
          @query_to_sql += " where action = '#{@action}'" unless @action.blank?
          @query_to_sql += " and #{@date_range.to_sql}" unless @date_range.to_sql == "1=1"
          @query_to_sql += " and #{Query.host_filter_to_sql(@host)}" unless @host.nil?
          @query_to_sql += " and #{contexts_filter_to_sql}" unless @contexts.nil?
        end


        # TRANSLATE FOR TRUE DISPLAY OF DATA
        # select context_key_filter, context_value_filter, count(*) as num from (
        #   select group_concat(results.context_key) as context_key_filter, group_concat(results.context_value) as context_value_filter, appstats_entry_id from 
        #   (
        #     select context_key, context_value, appstats_entry_id from 
        #     (
        #       select 10 as display_order, context_key, context_value, appstats_entry_id from appstats_contexts where context_key in ('user') and appstats_entry_id in ( select id from appstats_entries where action = 'yourblahs' )
        #       union
        #       select 11 as display_order, context_key, context_value, appstats_entry_id from appstats_contexts where context_key in ('service_provider') and appstats_entry_id in ( select id from appstats_entries where action = 'yourblahs' )
        #     ) inner_results order by display_order
        #   ) results group by appstats_entry_id
        # ) results group by context_value_filter;

        # OR, if we don't mind the sorting being done in the application
        # select context_key_filter, context_value_filter, count(*) as num from (
        #   select group_concat(results.context_key) as context_key_filter, group_concat(results.context_value) as context_value_filter, appstats_entry_id from 
        #   (
        #     select context_key, context_value, appstats_entry_id from appstats_contexts where context_key in ('user', 'service_provider') and appstats_entry_id in ( select id from appstats_entries where action = 'yourblahs' ) order by context_key
        #   ) results group by appstats_entry_id
        # ) results group by context_value_filter;

        unless @group_by.empty?
          query_to_sql_with_id = @query_to_sql.sub("count(*) as num","id")
          group_as_sql = @group_by.collect { |g| "#{Query.sqlquote(g)}" }.join(',')
          @group_query_to_sql = "select context_key_filter, context_value_filter, count(*) as num from (select group_concat(appstats_contexts.context_key) as context_key_filter, group_concat(appstats_contexts.context_value) as context_value_filter, appstats_entry_id from appstats_contexts where context_key in (#{group_as_sql}) and appstats_entry_id in ( #{query_to_sql_with_id} ) group by appstats_entry_id) results group by context_value_filter"
        end

        @query_to_sql
      end    
      
      def fix_legacy_structures(raw_input)
        query = raw_input.gsub(/on\s*server/,"on")
        query
      end  
   
      def sql_for_conext(context_name,contact_value)
        "EXISTS(select * from appstats_contexts where appstats_contexts.appstats_entry_id=appstats_entries.id and context_key='#{context_name}' and context_value='#{contact_value}' )"
      end
      
      def nil_query
        @query_to_sql = @@nill_query
        @query_to_sql
        @group_query_to_sql = nil
      end
      
      def reset_query
        @action = nil
        @host = nil
        nil_query
        @date_range = DateRange.new
        @group_by = []
        @contexts = nil
        @parsed_contexts = []
      end
    
  end
end