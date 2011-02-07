
module Appstats
  class Query

    @@default = "1=1"
    
    def self.parse_to_sql(raw_input)
      
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
    
  end
end