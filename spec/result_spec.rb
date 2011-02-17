require 'spec_helper'

module Appstats
  describe Result do

    before(:each) do
      @result = Appstats::Result.new
      Time.stub!(:now).and_return(Time.parse('2010-09-21 23:15:20'))
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
    
    describe "#date_to_s" do

      it "should handle nil" do
        @result.date_to_s.should == ""
      end

      it "should handle a from date only without a created_at date" do
        @result.from_date = Time.parse("2010-01-02 03:04:05")
        @result.date_to_s.should == "2010-01-02 to present"
      end

      
      it "should handle a from date only" do
        @result.from_date = Time.parse("2010-01-02 03:04:05")
        @result.save
        @result.date_to_s.should == "2010-01-02 to 2010-09-21"
      end

      it "should handle a to date only" do
        @result.to_date = Time.parse("2010-01-02 03:04:05")
        @result.date_to_s.should == "up to 2010-01-02"
      end

      it "should handle both a from and to date only" do
        @result.from_date = Time.parse("2009-01-02 03:04:05")
        @result.to_date = Time.parse("2010-01-02 03:04:05")
        @result.date_to_s.should == "2009-01-02 to 2010-01-02"
      end

      
    end
    
    describe "#from_date_to_s" do
      
      it "should handle nil" do
        @result.from_date_to_s.should == ""
      end
      
      it "should handle a date" do
        @result.from_date = Time.parse("2010-01-02 03:04:05")
        @result.from_date_to_s.should == "2010-01-02"
      end
      
    end

    describe "#to_date_to_s" do
      
      it "should handle nil" do
        @result.to_date_to_s.should == ""
      end
      
      it "should handle a date" do
        @result.to_date = Time.parse("2010-01-02 03:04:06")
        @result.to_date_to_s.should == "2010-01-02"
      end
      
    end
    
  end
end