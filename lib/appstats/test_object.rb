module Appstats
  class TestObject < ActiveRecord::Base
    set_table_name "appstats_test_objects"
    acts_as_appstatsable

    attr_accessible :name

    def to_s
      return "NILL" if name.nil?
      "[#{name}]"
    end
    
  end
end