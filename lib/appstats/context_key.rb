module Appstats
  class ContextKey < ActiveRecord::Base
    set_table_name "appstats_context_keys"
    establish_connection "appstats_#{Rails.env}" if configurations.keys.include?("appstats_#{Rails.env}")
    
    attr_accessible :name, :status

    def self.rename(old_key,new_key)
      sql = ["update appstats_context_keys set name = ?, updated_at = ? where name = ?",new_key,Time.now,old_key]
      Appstats.connection.update(ActiveRecord::Base.send(:sanitize_sql_array, sql))

      sql = ["update appstats_contexts set context_key = ?, updated_at = ? where context_key = ?",new_key,Time.now,old_key]
      Appstats.connection.update(ActiveRecord::Base.send(:sanitize_sql_array, sql))

      sql = ["update appstats_action_context_keys set context_key = ?, updated_at = ? where context_key = ?",new_key,Time.now,old_key]
      Appstats.connection.update(ActiveRecord::Base.send(:sanitize_sql_array, sql))

    end

    def self.update_context_keys
      sql = "select distinct(context_key) from appstats_contexts where context_key not in (select name from appstats_context_keys)"
      count = 0
      Appstats.connection.execute(sql).each do |row| 
        Appstats::ContextKey.create(:name => row[0], :status => 'derived')
        count += 1
      end
      count
    end
  
  end
end