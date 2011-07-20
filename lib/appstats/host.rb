module Appstats
  class Host < ActiveRecord::Base
    set_table_name "appstats_hosts"
    establish_connection "appstats_#{Rails.env}" if configurations.keys.include?("appstats_#{Rails.env}")
    
    attr_accessible :name, :status

    def self.update_hosts
      sql = "select distinct(host) from appstats_log_collectors where host not in (select name from appstats_hosts)"
      count = 0
      Appstats.connection.execute(sql).each do |row| 
        Appstats::Host.create(:name => row[0], :status => 'derived')
        count += 1
      end
      count
    end
  
  end
end