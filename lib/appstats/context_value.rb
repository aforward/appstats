module Appstats
  class ContextValue < ActiveRecord::Base
    self.table_name = "appstats_context_values"
    establish_connection "appstats_#{Rails.env}" if configurations.keys.include?("appstats_#{Rails.env}")
    
    attr_accessible :name, :status

    def self.update_context_values
      sql = "select distinct(context_value) from appstats_contexts where context_value not in (select name from appstats_context_values)"
      count = 0
      Appstats.connection.execute(sql).each do |row| 
        Appstats::ContextValue.create(:name => row[0], :status => 'derived')
        count += 1
      end
      count
    end
  
  end
end