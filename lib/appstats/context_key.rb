module Appstats
  class ContextKey < ActiveRecord::Base
    set_table_name "appstats_context_keys"
    
    attr_accessible :name, :status

    def self.update_context_keys
      sql = "select distinct(context_key) from appstats_contexts where context_key not in (select name from appstats_context_keys)"
      count = 0
      ActiveRecord::Base.connection.execute(sql).each do |row| 
        Appstats::ContextKey.create(:name => row[0], :status => 'derived')
        count += 1
      end
      count
    end
  
  end
end