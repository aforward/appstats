
module Appstats
  class Query

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
        @query_to_sql = "select count(*) from appstats_entries"
        @action = nil
        @host = nil
        @date_range = DateRange.new
        return @query_to_sql if @query.nil?
        current_query = @query

        m = current_query.match(/^\s*(\#)\s*([^\s]*)\s*(.*)/)
        return @query_to_sql if m.nil?
        if m[1] == "#"
          @action = normalize_action_name(m[2])
          @query_to_sql += " where action = '#{@action}'"
        end
        current_query = m[3]

        m_on_server = current_query.match(/^(.*)?\s*on\s*server\s*(.*)$/)
        date_range_text = m_on_server.nil? ? current_query : m_on_server[1]
        if date_range_text.size > 0
          @date_range = DateRange.parse(date_range_text)
          @query_to_sql += " and #{@date_range.to_sql}" unless @date_range.to_sql == "1=1"
        end
        return @query_to_sql if m_on_server.nil?

        @host = m_on_server[2]
        @query_to_sql += " and exists (select * from appstats_log_collectors where appstats_entries.appstats_log_collector_id = appstats_log_collectors.id and host = '#{@host}')"

        @query_to_sql
      end      
    
    
  end
end