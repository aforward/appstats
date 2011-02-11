require 'spec_helper'

module Appstats
  describe Result do

    before(:each) do
      @result = Appstats::Result.new
    end

    describe "#initialize" do
    
      it "should set attributes to nil" do
        @result.name.should == nil
        @result.result_type.should == nil
        @result.query.should == nil
        @result.query_as_sql.should == nil
        @result.count.should == nil
        @result.action.should == nil
        @result.action.should == nil
      end
    
      it "should set on constructor" do
        result = Appstats::Result.new(:name => 'a', :result_type => 'b', :query => 'c', :query_as_sql => 'd', :count => 10, :action => 'e', :host => 'f')
        result.name.should == 'a'
        result.result_type.should == 'b'
        result.query.should == 'c'
        result.query_as_sql.should == 'd'
        result.count.should == 10
        result.action.should == 'e'
        result.host.should == 'f'
      end
    
    end
    
    describe "#==" do
      
      it "should be equal on all attributes" do
        result = Appstats::Result.new(:name => 'a', :result_type => 'b', :query => 'c', :query_as_sql => 'd', :count => 10, :action => 'e', :host => 'f')
        same_result = Appstats::Result.new(:name => 'a', :result_type => 'b', :query => 'c', :query_as_sql => 'd', :count => 10, :action => 'e', :host => 'f')
        (result == same_result).should == true
      end
      
      it "should be not equal if diferent attributes" do
        result = Appstats::Result.new(:name => 'a', :result_type => 'b', :query => 'c', :query_as_sql => 'd', :count => 10, :action => 'e', :host => 'f')
        different_result = Appstats::Result.new(:name => 'xxx', :result_type => 'b', :query => 'c', :query_as_sql => 'd', :count => 10, :action => 'e', :host => 'f')  
        
        [:name,:result_type,:query,:query_as_sql,:count,:action,:host].each do |attr|
          different_result = Appstats::Result.new(:name => 'a', :result_type => 'b', :query => 'c', :query_as_sql => 'd', :count => 10, :action => 'e', :host => 'f')  
          different_result.send("#{attr}=","XXX")
          
          different_result.should_not == result
          (different_result == result).should == false
        end
      end

    end
  end
end