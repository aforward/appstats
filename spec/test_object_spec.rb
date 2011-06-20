require 'spec_helper'

module Appstats
  describe TestObject do

    before(:each) do
      @obj = Appstats::TestObject.new
    end

    describe "#initialize" do
    
      it "should set name to nil" do
        @obj.name.should == nil
        @obj.last_name.should == nil
      end
    
      it "should set on constructor" do
        obj = Appstats::TestObject.new(:name => 'a', :last_name => 'b')
        obj.name.should == 'a'
        obj.last_name.should == 'b'
      end
    
    end
    
    describe "#to_s" do
      
      it "should support nil" do
        obj = Appstats::TestObject.new
        obj.to_s.should == "NILL"
        obj.name = ""
        obj.to_s.should == "[]"
      end
      
      it "should display the name" do
        Appstats::TestObject.new(:name => 'x').to_s.should == '[x]'
      end
      
    end
  end
end