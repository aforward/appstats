class AppstatsEntry < ActiveRecord::Base
  
  attr_accessible :entry_type, :name, :description
  
  
  def to_s
    "Entry [type],[name],[description]"
  end
  
end