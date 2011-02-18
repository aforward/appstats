
module Appstats
  class Query

    @@parser_template = Appstats::Parser.new(:rules => ":operation :action :date on :host where :contexts")
    @@contexts_parser_template = Appstats::Parser.new(:rules => ":context", :repeating => true, :tokenize => "and or || && = <= >= <> != ( ) like")

    @@nill_query = "select 0 from appstats_entries LIMIT 1"
    @@default = "1=1"
    attr_accessor :query, :action, :host, :date_range, :query_to_sql, :contexts

    def initialize(data = {})
      self.query=(data[:query])
    end
    
    def query=(value)
      @query = value
      parse_query
    end
    
    def run
      result = Appstats::Result.new(:result_type => :on_demand, :query => @query, :query_as_sql => @query_to_sql, :action => @action, :host => @host, :from_date => @date_range.from_date, :to_date => @date_range.to_date, :contexts => @contexts)
      result.count = ActiveRecord::Base.connection.select_one(@query_to_sql)["count(*)"].to_i
      result.save
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
        
        if @operation == "#"
          @query_to_sql = "select count(*) from appstats_entries"
          @query_to_sql += " where action = '#{@action}'" unless @action.blank?
          @query_to_sql += " and #{@date_range.to_sql}" unless @date_range.to_sql == "1=1"
          @query_to_sql += " and #{Query.host_filter_to_sql(@host)}" unless @host.nil?
          @query_to_sql += " and #{Query.contexts_filter_to_sql(@contexts)}" unless @contexts.nil?
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
      end
      
      def reset_query
        @action = nil
        @host = nil
        nil_query
        @date_range = DateRange.new
      end
    
  end
end