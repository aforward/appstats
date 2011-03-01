
module Appstats
  class Query

    @@parser_template = Appstats::Parser.new(:rules => ":operation :action :date on :host where :contexts group by :group_by")
    @@contexts_parser_template = Appstats::Parser.new(:rules => ":context", :repeating => true, :tokenize => "and or || && = <= >= <> != ( ) like")
    @@group_by_parser_template = Appstats::Parser.new(:rules => ":filter", :repeating => true, :tokenize => ",")

    @@nill_query = "select 0 from appstats_entries LIMIT 1"
    @@default = "1=1"
    attr_accessor :name, :query, :action, :host, :date_range, :query_to_sql, :contexts, :group_by, :group_query_to_sql

    def initialize(data = {})
      @name = data[:name]
      @result_type = data[:result_type] || "on_demand"
      self.query=(data[:query])
    end
    
    def query=(value)
      @query = value
      parse_query
    end
    
    def run
      result = Appstats::Result.new(:name => @name, :result_type => @result_type, :query => @query, :query_as_sql => @query_to_sql, :action => @action, :host => @host, :from_date => @date_range.from_date, :to_date => @date_range.to_date, :contexts => @contexts)
      result.group_by = @group_by.join(", ") unless @group_by.empty?
      result.count = ActiveRecord::Base.connection.select_one(@query_to_sql)["count(*)"].to_i
      result.save
      
      unless @group_by.empty?
        all_sub_results = ActiveRecord::Base.connection.select_all(@group_query_to_sql)
        all_sub_results.each do |data|
          keys = data["context_key_filter"].split(",")
          values = data["context_value_filter"].split(",")
          key_values = {} and keys.each_with_index { |k,i| key_values[k] = values[i] }
          ratio_of_total = data["num"].to_f / result.count
          sub_result = Appstats::SubResult.new(:context_filter => @group_by.collect { |k| key_values[k] }.join(", "), :count => data["num"], :ratio_of_total => ratio_of_total)
          sub_result.result = result
          sub_result.save
        end
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

    def self.contexts_filter_to_sql(raw_input)
      context_parser = @@contexts_parser_template.dup
      return @@default if (raw_input.blank? || !context_parser.parse(raw_input))
      sql = "EXISTS (select * from appstats_contexts where appstats_entries.id = appstats_contexts.appstats_entry_id and ("
      
      status = :next
      comparator = "="
      context_parser.raw_results.each do |entry|
        if entry.kind_of?(String)
          sqlentry = sqlize(entry)
          if Query.comparator?(entry) && status == :waiting_comparator
            comparator = sqlize(entry)
            status = :waiting_operand
          else
            sql += ")" if status == :waiting_comparator
            sql += " #{sqlentry}"
            status = :next
          end
          next
        end
        if status == :next
          status = :waiting_comparator
          sql += " (context_key = '#{sqlclean(entry[:context])}'"
        else
          status = :next
          sql += " and context_value #{comparator} '#{sqlclean(entry[:context])}')"
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
      ["=","!=","<>",">","<",">=","<=","like"]
    end
    
    private
    
      def normalize_action_name(action_name)
        action = Appstats::Action.where("plural_name = ?",action_name).first
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
        @contexts = parser.results[:contexts]
        parse_group_by(parser.results[:group_by])
        
        if @operation == "#"
          @query_to_sql = "select count(*) from appstats_entries"
          @query_to_sql += " where action = '#{@action}'" unless @action.blank?
          @query_to_sql += " and #{@date_range.to_sql}" unless @date_range.to_sql == "1=1"
          @query_to_sql += " and #{Query.host_filter_to_sql(@host)}" unless @host.nil?
          @query_to_sql += " and #{Query.contexts_filter_to_sql(@contexts)}" unless @contexts.nil?
        end

        unless @group_by.empty?
          query_to_sql_with_id = @query_to_sql.sub("count(*)","id")
          group_as_sql = @group_by.collect { |g| "'#{Query.sqlclean(g)}'" }.join(',')
          @group_query_to_sql = "select context_key_filter, context_value_filter, count(*) num from (select group_concat(appstats_contexts.context_key) as context_key_filter, group_concat(appstats_contexts.context_value) as context_value_filter, appstats_entry_id from appstats_contexts where context_key in (#{group_as_sql}) and appstats_entry_id in ( #{query_to_sql_with_id} ) group by appstats_entry_id) results group by context_value_filter;"
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
      end
    
  end
end