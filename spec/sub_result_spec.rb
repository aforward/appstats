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
    
    describe "#count_to_s" do

      it "should handle nil" do
        @sub_result.count = nil
        @sub_result.count_to_s.should == '--'
      end

      it "should handle 0" do
        @sub_result.count = 0
        @sub_result.count_to_s.should == '0'
      end

      it "should handle < 1000 numbers" do
        @sub_result.count = 123
        @sub_result.count_to_s.should == "123"
      end

      it "should handle > 1000 numbers" do
        @sub_result.count = 1000
        @sub_result.count_to_s.should == "1,000"

        @sub_result.count = 12345
        @sub_result.count_to_s.should == "12,345"

      end

      it "should handle > 1000000 numbers" do
        @sub_result.count = 1000000
        @sub_result.count_to_s.should == "1,000,000"

        @sub_result.count = 1234567
        @sub_result.count_to_s.should == "1,234,567"
      end

      describe "short_hand format" do


        it "should handle trillion" do
          @sub_result.count = 1400000000000
          @sub_result.count_to_s(:format => :short_hand).should == "1.4 trillion"
        end

        it "should handle billion" do
          @sub_result.count = 1490000000
          @sub_result.count_to_s(:format => :short_hand).should == "1.5 billion"

          @sub_result.count = 91490000000
          @sub_result.count_to_s(:format => :short_hand).should == "91.5 billion"

        end

        it "should handle million" do
          @sub_result.count = 1200000
          @sub_result.count_to_s(:format => :short_hand).should == "1.2 million"

          @sub_result.count = 881200000
          @sub_result.count_to_s(:format => :short_hand).should == "881.2 million"
        end

        it "should handle thousand" do
          @sub_result.count = 1200
          @sub_result.count_to_s(:format => :short_hand).should == "1.2 thousand"

          @sub_result.count = 912600
          @sub_result.count_to_s(:format => :short_hand).should == "912.6 thousand"

        end

        it "should not display decimal if 0" do
          @sub_result.count = 1000
          @sub_result.count_to_s(:format => :short_hand).should == "1 thousand"

          @sub_result.count = 912000
          @sub_result.count_to_s(:format => :short_hand).should == "912 thousand"

        end
      end
    end    

    describe "#total_count_to_s" do
      
      it "should be zero if no result" do
        @sub_result.total_count_to_s.should == "0"
      end
      
      it "should be based on result.count" do
        @sub_result.result = Result.create(:count => 1000)
        @sub_result.total_count_to_s.should == "1,000"
      end
      
    end
    
    
  end
end