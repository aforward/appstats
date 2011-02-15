
module Appstats
  class Query

    @@nill_query = "select 0 from appstats_entries LIMIT 1"
    @@default = "1=1"
    attr_accessor :query, :action, :host, :date_range, :query_to_sql

    def initialize(data = {})
      self.query=(data[:query])
    end
    
    def query=(value)
      @query = value
      parse_query
    end
    
    def run
      result = Appstats::Result.new(:result_type => :on_demand, :query => @query, :query_as_sql => @query_to_sql, :action => @action, :host => @host, :from_date => @date_range.from_date, :to_date => @date_range.to_date)
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
      "EXISTS (select * from appstats_log_collectors where appstats_entries.appstats_log_collector_id = id and host = '#{host}' )"
    end

    def self.context_filter_to_sql(raw_input)
      return @@default if raw_input.nil?
      m = raw_input.match(/([^']+)=([^']+)/)
      return @@default if m.nil?
      key = m[1].strip
      value = m[2].strip
      return @@default if key == '' or key.nil?
      "EXISTS (select * from appstats_contexts where appstats_entries.id = appstats_contexts.appstats_entry_id and context_key='#{key}' and context_value='#{value}' )"
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
        
        parser = Appstats::Parser.new(:rules => ":operation :action :date on :host where :contexts")
        return nil_query unless parser.parse(current_query)
        
        @operation = parser.results[:operation]
        @action = normalize_action_name(parser.results[:action])
        @date_range = DateRange.parse(parser.results[:date])
        @host = parser.results[:host]
        @contexts = parser.results[:host]

        if @operation == "#"
          @query_to_sql = "select count(*) from appstats_entries"
          @query_to_sql += " where action = '#{@action}'" unless @action.blank?
          @query_to_sql += " and #{@date_range.to_sql}" unless @date_range.to_sql == "1=1"
          @query_to_sql += " and exists (select * from appstats_log_collectors where appstats_entries.appstats_log_collector_id = appstats_log_collectors.id and host = '#{@host}')" unless @host.nil?
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