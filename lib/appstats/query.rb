
module Appstats
  class Query

    @@default = "1=1"
    attr_accessor :input

    def initialize(data = {})
      @input = data[:input]
    end
    
    def to_sql
      sql = "select count(*) from appstats_entries"
      return sql if @input.nil?
      m = @input.match(/^\s*(\#)\s*([^\s]*)\s*(.*)/)
      return sql if m.nil?
      if m[1] == "#"
        sql += " where action = '#{normalize_action_name(m[2])}'"
      end
      m = m[3].match(/^since\s*(.*)$/)
      return sql if m.nil?
      range = DateRange.parse(m[1])

      sql
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
    
    
  end
end