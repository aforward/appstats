
class AppstatsEntry < ActiveRecord::Base
  
  def to_s
    "Entry [type],[name],[description]"
  end
  
end