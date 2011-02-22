module Appstats
  class ContextValue < ActiveRecord::Base
    set_table_name "appstats_context_values"
    
    attr_accessible :name, :status

    def self.update_context_values
      sql = "select distinct(context_value) from appstats_contexts where context_value not in (select name from appstats_context_values)"
      count = 0
      ActiveRecord::Base.connection.execute(sql).each do |row| 
        Appstats::ContextValue.create(:name => row[0], :status => 'derived')
        count += 1
      end
      count
    end
  
  end
end