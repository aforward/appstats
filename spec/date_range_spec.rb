require 'spec_helper'

module Appstats
  describe DateRange do


    before(:each) do
      @time = Time.parse('2010-01-15 10:20:30')
      Time.stub!(:now).and_return(@time)
    end

    describe "#initialize" do
      
      it "should set format to true if not set" do
        DateRange.new.format.should == "inclusive"
        DateRange.new(:format => "exclusive").format.should == "exclusive"
      end
      
      it "should understand from date and to date" do
        date_range = DateRange.new(:from => EntryDate.new(:year => 2009), :to => EntryDate.new(:year => 2010), :format => "inclusive")
        date_range.from.year.should == 2009
        date_range.to.year.should == 2010
        date_range.format.should == "inclusive"
      end
      
      it "should understand equality" do
        date_range = DateRange.new(:from => EntryDate.new(:year => 2009), :to => EntryDate.new(:year => 2010))
        same_date_range = DateRange.new(:from => EntryDate.new(:year => 2009), :to => EntryDate.new(:year => 2010))
        another_date_range = DateRange.new(:from => EntryDate.new(:year => 2007), :to => EntryDate.new(:year => 2010))
        
        date_range.should == date_range
        date_range.should == same_date_range
        date_range.should_not == another_date_range
      end
    end
    
    describe "#parse" do
      
      it "should understand nil" do
        DateRange.parse(nil).should == DateRange.new
        DateRange.parse("").should == DateRange.new
      end
      
      it "should understand between" do
        range = DateRange.parse("  between Mar, 2010 and Jun, 2011  ")
        range.should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 3), :to => EntryDate.new(:year => 2011, :month => 6), :format => "inclusive" )
      end

      it "should understand in" do
        range = DateRange.parse("  in Mar, 2010  ")
        range.should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 3), :to => nil, :format => "fixed_point" )
      end

      it "should understand on" do
        range = DateRange.parse("  on Mar, 2010  ")
        range.should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 3), :to => nil, :format => "fixed_point" )
      end
      
      describe "before and after dates" do

        it "should understand before" do
          range = DateRange.parse("  before Mar, 2010  ")
          range.should == DateRange.new(:from => nil, :to => EntryDate.new(:year => 2010, :month => 3), :format => "exclusive" )
        end

        it "should understand after" do
          range = DateRange.parse("  after Mar, 2010  ")
          range.should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 3), :to => nil, :format => "exclusive" )
        end
        
      end
      
      
      it "should understand YTD, today, yesterday" do
        DateRange.parse("  YTD  ").should == DateRange.new(:from => EntryDate.new(:year => 2010), :to => nil, :format => "fixed_point" )
        DateRange.parse("  today  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 15), :to => nil, :format => "fixed_point" )
        DateRange.parse("  yesterday  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 14), :to => nil, :format => "fixed_point" )
      end

      describe "this (year|month|week|day)" do

        it "should understand this year" do
          DateRange.parse("  this year  ").should == DateRange.new(:from => EntryDate.new(:year => 2010), :to => nil, :format => "fixed_point" )
        end

        it "should understand this month" do
          DateRange.parse("  this month  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1), :to => nil, :format => "fixed_point" )
        end

        it "should understand this week" do
          DateRange.parse("  this week  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 11), :to => nil, :format => "inclusive" )
        end

        it "should understand this day" do
          DateRange.parse("  this day  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 15), :to => nil, :format => "fixed_point" )
        end
                
      end

      describe "(last|previous) (year|month|week|day)" do

        it "should understand last year" do
          DateRange.parse("  last year  ").should == DateRange.new(:from => EntryDate.new(:year => 2009), :to => nil, :format => "fixed_point" )
        end

        it "should understand last month" do
          DateRange.parse("  last month  ").should == DateRange.new(:from => EntryDate.new(:year => 2009, :month => 12), :to => nil, :format => "fixed_point" )
        end

        it "should understand last week" do
          DateRange.parse("  last week  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 4), :to => EntryDate.new(:year => 2010, :month => 1, :day => 10), :format => "inclusive" )
        end

        it "should understand last day" do
          DateRange.parse("  last day  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 14), :to => nil, :format => "fixed_point" )
        end
        
        it "should understand previous year" do
          DateRange.parse("  previous year  ").should == DateRange.new(:from => EntryDate.new(:year => 2009), :to => nil, :format => "fixed_point" )
        end

        it "should understand previous month" do
          DateRange.parse("  previous month  ").should == DateRange.new(:from => EntryDate.new(:year => 2009, :month => 12), :to => nil, :format => "fixed_point" )
        end

        it "should understand previous week" do
          DateRange.parse("  previous week  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 4), :to => EntryDate.new(:year => 2010, :month => 1, :day => 10), :format => "inclusive" )
        end

        it "should understand previous day" do
          DateRange.parse("  previous day  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 14), :to => nil, :format => "fixed_point" )
        end
                
      end

      describe "last X (year|month|week|day)s" do
        
        it "should understand last X years" do
          DateRange.parse("  last 1 year  ").should == DateRange.new(:from => EntryDate.new(:year => 2010), :to => nil, :format => "inclusive" )
          DateRange.parse("  last 2 years  ").should == DateRange.new(:from => EntryDate.new(:year => 2009), :to => nil, :format => "inclusive" )
          DateRange.parse("  last 3 years  ").should == DateRange.new(:from => EntryDate.new(:year => 2008), :to => nil, :format => "inclusive" )
        end

        it "should understand last X months" do
          DateRange.parse("  last 1 month  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1), :to => nil, :format => "inclusive" )
          DateRange.parse("  last 2 months  ").should == DateRange.new(:from => EntryDate.new(:year => 2009, :month => 12), :to => nil, :format => "inclusive" )
          DateRange.parse("  last 3 months  ").should == DateRange.new(:from => EntryDate.new(:year => 2009, :month => 11), :to => nil, :format => "inclusive" )
        end

        it "should understand last X weeks" do
          DateRange.parse("  last 1 week  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 11), :to => nil, :format => "inclusive" )
          DateRange.parse("  last 2 weeks  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 4), :to => nil, :format => "inclusive" )
          DateRange.parse("  last 3 weeks  ").should == DateRange.new(:from => EntryDate.new(:year => 2009, :month => 12, :day => 28), :to => nil, :format => "inclusive" )
        end

        it "should understand last X days" do
          DateRange.parse("  last 1 day  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 15), :to => nil, :format => "inclusive" )
          DateRange.parse("  last 2 days  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 14), :to => nil, :format => "inclusive" )
          DateRange.parse("  last 3 days  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 13), :to => nil, :format => "inclusive" )
        end

      end

      describe "previous X (year|month|week|day)s" do
      
        it "should understand previous X years" do
          DateRange.parse("  previous 1 year  ").should == DateRange.new(:from => EntryDate.new(:year => 2009), :to => EntryDate.new(:year => 2009), :format => "inclusive" )
          DateRange.parse("  previous 2 years  ").should == DateRange.new(:from => EntryDate.new(:year => 2008), :to => EntryDate.new(:year => 2009), :format => "inclusive" )
          DateRange.parse("  previous 3 years  ").should == DateRange.new(:from => EntryDate.new(:year => 2007), :to => EntryDate.new(:year => 2009), :format => "inclusive" )
        end

        it "should understand previous Y months" do
          DateRange.parse("  previous 1 month  ").should == DateRange.new(:from => EntryDate.new(:year => 2009, :month => 12), :to => EntryDate.new(:year => 2009, :month => 12), :format => "inclusive" )
          DateRange.parse("  previous 2 months  ").should == DateRange.new(:from => EntryDate.new(:year => 2009, :month => 11), :to => EntryDate.new(:year => 2009, :month => 12), :format => "inclusive" )
          DateRange.parse("  previous 3 months  ").should == DateRange.new(:from => EntryDate.new(:year => 2009, :month => 10), :to => EntryDate.new(:year => 2009, :month => 12), :format => "inclusive" )
        end

        it "should understand previous 2 weeks" do
          DateRange.parse("  previous 1 week  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 4), :to => EntryDate.new(:year => 2010, :month => 1, :day => 10), :format => "inclusive" )
          DateRange.parse("  previous 2 weeks  ").should == DateRange.new(:from => EntryDate.new(:year => 2009, :month => 12, :day => 28), :to => EntryDate.new(:year => 2010, :month => 1, :day => 10), :format => "inclusive" )
          DateRange.parse("  previous 3 weeks  ").should == DateRange.new(:from => EntryDate.new(:year => 2009, :month => 12, :day => 21), :to => EntryDate.new(:year => 2010, :month => 1, :day => 10), :format => "inclusive" )
        end

        it "should understand previous 2 days" do
          DateRange.parse("  previous 1 day  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 14), :to => EntryDate.new(:year => 2010, :month => 1, :day => 14), :format => "inclusive" )
          DateRange.parse("  previous 2 days  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 13), :to => EntryDate.new(:year => 2010, :month => 1, :day => 14), :format => "inclusive" )
          DateRange.parse("  previous 3 days  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 12), :to => EntryDate.new(:year => 2010, :month => 1, :day => 14), :format => "inclusive" )
        end      

      end
      
    end
    
    
  end
end