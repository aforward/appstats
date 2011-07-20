
module Appstats
  class Action < ActiveRecord::Base
    set_table_name "appstats_actions"
    establish_connection "appstats_#{Rails.env}" if configurations.keys.include?("appstats_#{Rails.env}")
    
    attr_accessible :name, :plural_name, :status

    def self.update_actions
      sql = "select distinct(action) from appstats_entries where action not in (select name from appstats_actions)"
      count = 0
      Appstats.connection.execute(sql).each do |row| 
        Appstats::Action.create(:name => row[0], :plural_name => row[0].pluralize, :status => 'derived')
        count += 1
      end
      count
    end
  
  end
end