
module Appstats
  class ActionContextKey < ActiveRecord::Base
    self.table_name = "appstats_action_context_keys"
    establish_connection "appstats_#{Rails.env}" if configurations.keys.include?("appstats_#{Rails.env}")
    
    attr_accessible :action_name, :context_key, :status
  
    def self.update_action_context_keys
      sql = "select action,context_key,count(*) as num
      from appstats_entries 
      inner join appstats_contexts on appstats_contexts.appstats_entry_id = appstats_entries.id
      where (action,context_key) not in (select action_name, context_key from appstats_action_context_keys)
      group by action,context_key"
      count = 0
      Appstats.connection.execute(sql).each do |row| 
        Appstats::ActionContextKey.create(:action_name => row[0], :context_key => row[1], :status => 'derived')
        count += 1
      end
      count
    end
    
  end
end