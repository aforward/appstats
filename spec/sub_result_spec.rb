require 'spec_helper'

module Appstats
  describe SubResult do

    before(:each) do
      @sub_result = Appstats::SubResult.new
      Time.stub!(:now).and_return(Time.parse('2010-09-21 23:15:20'))
    end

    describe "#initialize" do
    
      it "should set attributes to nil" do
        @sub_result.context_filter.should == nil
        @sub_result.count.should == nil
        @sub_result.ratio_of_total.should == nil
      end
    
      it "should set on constructor" do
        sub_result = Appstats::SubResult.new(:context_filter => 'a', :count => 1, :ratio_of_total => 0.2)
        sub_result.context_filter.should == 'a'
        sub_result.count.should == 1
        sub_result.ratio_of_total.should == 0.2
      end
    
    end
    
    describe "#result" do
      
      it "should be nil be default" do
        @sub_result.result.should == nil
      end
      
      it "should be settable" do
        @result = Result.create
        @sub_result.result = @result
        @sub_result.save.should == true
        
        @sub_result.reload
        @result.reload
        
        @sub_result.result.should == @result
        @result.sub_results.should == [@sub_result]
      end
      
    end
    
    describe "#==" do
      
      it "should be equal on all attributes" do
        sub_result = Appstats::SubResult.new(:context_filter => 'a', :count => 1, :ratio_of_total => 0.2)
        same_sub_result = Appstats::SubResult.new(:context_filter => 'a', :count => 1, :ratio_of_total => 0.2)
        (sub_result == same_sub_result).should == true
      end

      it "should be not equal if diferent attributes" do
        sub_result = Appstats::SubResult.new(:context_filter => 'a', :count => 1, :ratio_of_total => 0.2)
        
        [:context_filter,:count,:ratio_of_total].each do |attr|
          different_sub_result = Appstats::SubResult.new(:context_filter => 'a', :count => 1, :ratio_of_total => 0.2)  
          different_sub_result.context_filter = "XXX" if attr == :context_filter
          different_sub_result.count = 11 if attr == :count
          different_sub_result.ratio_of_total = 0.22 if attr == :ratio_of_total
          
          different_sub_result.should_not == sub_result
        end
      end

    end
    
    describe "#total_count" do
      
      it "should be zero if no result" do
        @sub_result.total_count.should == 0
      end
      
      it "should be based on result.count" do
        @sub_result.result = Result.create(:count => 10)
        @sub_result.total_count.should == 10
      end
      
    end
    
  end
end