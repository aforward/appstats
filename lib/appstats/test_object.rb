module Appstats
  class TestObject < ActiveRecord::Base
    set_table_name "appstats_test_objects"
    acts_as_appstatsable
    acts_as_auditable

    attr_accessible :name, :last_name

    # after_save :blah
    # 
    # def blah
    #   puts "#{changed_attributes.inspect}"
    # end

    def to_s
      return "NILL" if name.nil?
      "[#{name}]"
    end
    
  end
end