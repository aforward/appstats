
module Appstats
  class Entry < ActiveRecord::Base
    set_table_name "appstats_entries"
    
    attr_accessible :entry_type, :name, :description
  
    def to_s
      "Entry [type],[name],[description]"
    end
  
  end
end