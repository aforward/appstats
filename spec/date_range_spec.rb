require 'spec_helper'

module Appstats
  describe DateRange do


    before(:each) do
      @time = Time.parse('2010-01-15 10:20:30')
      Time.stub!(:now).and_return(@time)
    end

    describe "#initialize" do
      
      it "should set format to true if not set" do
        DateRange.new.format.should == :inclusive
        DateRange.new(:format => :exclusive).format.should == :exclusive
      end
      
      it "should understand from date and to date" do
        date_range = DateRange.new(:from => EntryDate.new(:year => 2009), :to => EntryDate.new(:year => 2010), :format => :inclusive)
        date_range.from.year.should == 2009
        date_range.to.year.should == 2010
        date_range.format.should == :inclusive
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
        range.should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 3), :to => EntryDate.new(:year => 2011, :month => 6), :format => :inclusive )
      end
      
      describe "real examples" do
        
        it "should understand 'between Mar 6, 2011 and Mar 12, 2011'" do
          range = DateRange.parse("  between Mar 6, 2011 and Mar 12, 2011  ")
          range.should == DateRange.new(:from => EntryDate.new(:year => 2011, :month => 3, :day => 6), :to => EntryDate.new(:year => 2011, :month => 3, :day => 12), :format => :inclusive )
        end
        
      end

      it "should understand in" do
        range = DateRange.parse("  in Mar, 2010  ")
        range.should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 3), :to => nil, :format => :fixed_point )
      end

      it "shouldunderstand since" do
        DateRange.parse("  since Mar, 2010  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 3), :to => nil, :format => :inclusive )
        DateRange.parse("  since 2010-04-15  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 4, :day => 15), :to => nil, :format => :inclusive )
      end

      it "should understand on" do
        range = DateRange.parse("  on Mar, 2010  ")
        range.should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 3), :to => nil, :format => :fixed_point )
      end
      
      describe "before and after dates" do

        it "should understand before" do
          range = DateRange.parse("  before Mar, 2010  ")
          range.should == DateRange.new(:from => nil, :to => EntryDate.new(:year => 2010, :month => 3), :format => :exclusive )
        end

        it "should understand after" do
          range = DateRange.parse("  after Mar, 2010  ")
          range.should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 3), :to => nil, :format => :exclusive )
        end
        
      end
      
      
      it "should understand YTD, today, yesterday" do
        DateRange.parse("  YTD  ").should == DateRange.new(:from => EntryDate.new(:year => 2010), :to => nil, :format => :fixed_point )
        DateRange.parse("  today  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 15), :to => nil, :format => :fixed_point )
        DateRange.parse("  yesterday  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 14), :to => nil, :format => :fixed_point )
      end

      describe "this (year|quarter|month|week|day)" do

        it "should understand this year" do
          DateRange.parse("  this year  ").should == DateRange.new(:from => EntryDate.new(:year => 2010), :to => nil, :format => :fixed_point )
        end

        it "should understand this quarter" do
          DateRange.parse("  this quarter  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :quarter => 1), :to => nil, :format => :fixed_point )
        end

        it "should understand this month" do
          DateRange.parse("  this month  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1), :to => nil, :format => :fixed_point )
        end

        it "should understand this week" do
          DateRange.parse("  this week  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 11, :week => 2), :to => nil, :format => :fixed_point )
        end

        it "should understand this day" do
          DateRange.parse("  this day  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 15), :to => nil, :format => :fixed_point )
        end
                
      end

      describe "(last|previous) (year|quarter|month|week|day)" do

        it "should understand last year" do
          DateRange.parse("  last year  ").should == DateRange.new(:from => EntryDate.new(:year => 2009), :to => nil, :format => :fixed_point )
        end

        it "should understand last quarter" do
          DateRange.parse("  last quarter  ").should == DateRange.new(:from => EntryDate.new(:year => 2009, :month => 10, :quarter => 4), :to => nil, :format => :fixed_point )
        end

        it "should understand last month" do
          DateRange.parse("  last month  ").should == DateRange.new(:from => EntryDate.new(:year => 2009, :month => 12), :to => nil, :format => :fixed_point )
        end

        it "should understand last week" do
          DateRange.parse("  last week  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 4, :week => 1), :to => nil, :format => :fixed_point )
        end

        it "should understand last day" do
          DateRange.parse("  last day  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 14), :to => nil, :format => :fixed_point )
        end
        
        it "should understand previous year" do
          DateRange.parse("  previous year  ").should == DateRange.new(:from => EntryDate.new(:year => 2009), :to => nil, :format => :fixed_point )
        end

        it "should understand previous month" do
          DateRange.parse("  previous month  ").should == DateRange.new(:from => EntryDate.new(:year => 2009, :month => 12), :to => nil, :format => :fixed_point )
        end

        it "should understand previous week" do
          DateRange.parse("  previous week  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 4, :week => 1), :to => nil, :format => :fixed_point )
        end

        it "should understand previous day" do
          DateRange.parse("  previous day  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 14), :to => nil, :format => :fixed_point )
        end
                
      end

      describe "X (year|quarter|month|week|day)s ago" do

        it "should understand last X years" do
          DateRange.parse("  1 year ago  ").should == DateRange.new(:from => EntryDate.new(:year => 2009), :to => nil, :format => :fixed_point )
          DateRange.parse("  2 years ago  ").should == DateRange.new(:from => EntryDate.new(:year => 2008), :to => nil, :format => :fixed_point )
          DateRange.parse("  3 years ago  ").should == DateRange.new(:from => EntryDate.new(:year => 2007), :to => nil, :format => :fixed_point )
        end

        it "should understand last X quarters" do
          DateRange.parse("  1 quarter ago  ").should == DateRange.new(:from => EntryDate.new(:year => 2009, :month => 10, :quarter => 4), :to => nil, :format => :fixed_point )
          DateRange.parse("  2 quarters ago  ").should == DateRange.new(:from => EntryDate.new(:year => 2009, :month => 7, :quarter => 3), :to => nil, :format => :fixed_point )
          DateRange.parse("  3 quarters ago  ").should == DateRange.new(:from => EntryDate.new(:year => 2009, :month => 4, :quarter => 2), :to => nil, :format => :fixed_point )
        end

        it "should understand last X months" do
          DateRange.parse("  1 month ago  ").should == DateRange.new(:from => EntryDate.new(:year => 2009, :month => 12), :to => nil, :format => :fixed_point )
          DateRange.parse("  2 months ago  ").should == DateRange.new(:from => EntryDate.new(:year => 2009, :month => 11), :to => nil, :format => :fixed_point )
          DateRange.parse("  3 months ago  ").should == DateRange.new(:from => EntryDate.new(:year => 2009, :month => 10), :to => nil, :format => :fixed_point )
        end

        it "should understand last X weeks" do
          DateRange.parse("  1 week ago  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 4, :week => 1), :to => nil, :format => :fixed_point )
          DateRange.parse("  2 weeks ago  ").should == DateRange.new(:from => EntryDate.new(:year => 2009, :month => 12, :day => 28, :week => 52), :to => nil, :format => :fixed_point )
          DateRange.parse("  3 weeks ago  ").should == DateRange.new(:from => EntryDate.new(:year => 2009, :month => 12, :day => 21, :week => 51), :to => nil, :format => :fixed_point )
        end

        it "should understand last X days" do
          DateRange.parse("  1 day ago  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 14), :to => nil, :format => :fixed_point )
          DateRange.parse("  2 days ago  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 13), :to => nil, :format => :fixed_point )
          DateRange.parse("  3 days ago  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 12), :to => nil, :format => :fixed_point )
        end

      end

      describe "last X (year|quarter|month|week|day)s" do
        
        it "should understand last X years" do
          DateRange.parse("  last 1 year  ").should == DateRange.new(:from => EntryDate.new(:year => 2010), :to => nil, :format => :inclusive )
          DateRange.parse("  last 2 years  ").should == DateRange.new(:from => EntryDate.new(:year => 2009), :to => nil, :format => :inclusive )
          DateRange.parse("  last 3 years  ").should == DateRange.new(:from => EntryDate.new(:year => 2008), :to => nil, :format => :inclusive )
        end

        it "should understand last X quarters" do
          DateRange.parse("  last 1 quarter  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :quarter => 1), :to => nil, :format => :inclusive )
          DateRange.parse("  last 2 quarters  ").should == DateRange.new(:from => EntryDate.new(:year => 2009, :month => 10, :quarter => 4), :to => nil, :format => :inclusive )
          DateRange.parse("  last 3 quarters  ").should == DateRange.new(:from => EntryDate.new(:year => 2009, :month => 7, :quarter => 3), :to => nil, :format => :inclusive )
        end

        it "should understand last X months" do
          DateRange.parse("  last 1 month  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1), :to => nil, :format => :inclusive )
          DateRange.parse("  last 2 months  ").should == DateRange.new(:from => EntryDate.new(:year => 2009, :month => 12), :to => nil, :format => :inclusive )
          DateRange.parse("  last 3 months  ").should == DateRange.new(:from => EntryDate.new(:year => 2009, :month => 11), :to => nil, :format => :inclusive )
        end

        it "should understand last X weeks" do
          DateRange.parse("  last 1 week  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 11, :week => 2), :to => nil, :format => :inclusive )
          DateRange.parse("  last 2 weeks  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 4, :week => 1), :to => nil, :format => :inclusive )
          DateRange.parse("  last 3 weeks  ").should == DateRange.new(:from => EntryDate.new(:year => 2009, :month => 12, :day => 28, :week => 52), :to => nil, :format => :inclusive )
        end

        it "should understand last X days" do
          DateRange.parse("  last 1 day  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 15), :to => nil, :format => :inclusive )
          DateRange.parse("  last 2 days  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 14), :to => nil, :format => :inclusive )
          DateRange.parse("  last 3 days  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 13), :to => nil, :format => :inclusive )
        end

      end

      describe "previous X (year|quarter|month|week|day)s" do
      
        it "should understand previous X years" do
          DateRange.parse("  previous 1 year  ").should == DateRange.new(:from => EntryDate.new(:year => 2009), :to => EntryDate.new(:year => 2009), :format => :inclusive )
          DateRange.parse("  previous 2 years  ").should == DateRange.new(:from => EntryDate.new(:year => 2008), :to => EntryDate.new(:year => 2009), :format => :inclusive )
          DateRange.parse("  previous 3 years  ").should == DateRange.new(:from => EntryDate.new(:year => 2007), :to => EntryDate.new(:year => 2009), :format => :inclusive )
        end

        it "should understand previous Y quarters" do
          DateRange.parse("  previous 1 quarter  ").should == DateRange.new(:from => EntryDate.new(:year => 2009, :month => 10, :quarter => 4), :to => EntryDate.new(:year => 2009, :month => 12, :quarter => 4), :format => :inclusive )
          DateRange.parse("  previous 2 quarters  ").should == DateRange.new(:from => EntryDate.new(:year => 2009, :month => 7, :quarter => 3), :to => EntryDate.new(:year => 2009, :month => 12, :quarter => 4), :format => :inclusive )
          DateRange.parse("  previous 3 quarters  ").should == DateRange.new(:from => EntryDate.new(:year => 2009, :month => 4, :quarter => 2), :to => EntryDate.new(:year => 2009, :month => 12, :quarter => 4), :format => :inclusive )
        end

        it "should understand previous Y months" do
          DateRange.parse("  previous 1 month  ").should == DateRange.new(:from => EntryDate.new(:year => 2009, :month => 12), :to => EntryDate.new(:year => 2009, :month => 12), :format => :inclusive )
          DateRange.parse("  previous 2 months  ").should == DateRange.new(:from => EntryDate.new(:year => 2009, :month => 11), :to => EntryDate.new(:year => 2009, :month => 12), :format => :inclusive )
          DateRange.parse("  previous 3 months  ").should == DateRange.new(:from => EntryDate.new(:year => 2009, :month => 10), :to => EntryDate.new(:year => 2009, :month => 12), :format => :inclusive )
        end

        it "should understand previous 2 weeks" do
          DateRange.parse("  previous 1 week  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 4, :week => 1), :to => EntryDate.new(:year => 2010, :month => 1, :day => 10, :week => 1), :format => :inclusive )
          DateRange.parse("  previous 2 weeks  ").should == DateRange.new(:from => EntryDate.new(:year => 2009, :month => 12, :day => 28, :week => 52), :to => EntryDate.new(:year => 2010, :month => 1, :day => 10, :week => 1), :format => :inclusive )
          DateRange.parse("  previous 3 weeks  ").should == DateRange.new(:from => EntryDate.new(:year => 2009, :month => 12, :day => 21, :week => 51), :to => EntryDate.new(:year => 2010, :month => 1, :day => 10, :week => 1), :format => :inclusive )
        end

        it "should understand previous 2 days" do
          DateRange.parse("  previous 1 day  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 14), :to => EntryDate.new(:year => 2010, :month => 1, :day => 14), :format => :inclusive )
          DateRange.parse("  previous 2 days  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 13), :to => EntryDate.new(:year => 2010, :month => 1, :day => 14), :format => :inclusive )
          DateRange.parse("  previous 3 days  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 12), :to => EntryDate.new(:year => 2010, :month => 1, :day => 14), :format => :inclusive )
        end      

      end
      
    end
   
   
    describe "#from_date_to_s" do
      it "should handle nil" do
        DateRange.new.from_date_to_s.should == nil
      end

      it "should be based on time" do
        DateRange.new(:from => EntryDate.new(:year => 2010)).from_date_to_s.should == "2010-01-01 00:00:00"
      end
      
      it "should be based on end_of time as-is for exclusive" do
        DateRange.new(:from => EntryDate.new(:year => 2009), :format => :exclusive).from_date_to_s.should == "2009-12-31 23:59:59"
        DateRange.new(:from => EntryDate.new(:year => 2009, :month => 2), :format => :exclusive).from_date_to_s.should == "2009-02-28 23:59:59"
        DateRange.new(:from => EntryDate.new(:year => 2009, :month => 2, :day => 15), :format => :exclusive).from_date_to_s.should == "2009-02-15 23:59:59"
      end
      
    end

    describe "#to_date_to_s" do
      it "should handle nil" do
        DateRange.new.to_date_to_s.should == nil
      end

      it "should be based on time as-is for exclusive" do
        DateRange.new(:to => EntryDate.new(:year => 2009), :format => :exclusive).to_date_to_s.should == "2009-01-01 00:00:00"
      end

      it "should be based on end_of time as-is for inclusive" do
        DateRange.new(:to => EntryDate.new(:year => 2009), :format => :inclusive).to_date_to_s.should == "2009-12-31 23:59:59"
        DateRange.new(:to => EntryDate.new(:year => 2009, :month => 2), :format => :inclusive).to_date_to_s.should == "2009-02-28 23:59:59"
        DateRange.new(:to => EntryDate.new(:year => 2009, :month => 2, :day => 15), :format => :inclusive).to_date_to_s.should == "2009-02-15 23:59:59"
      end


    end
    
    describe "#from_date" do
      it "should handle nil" do
        DateRange.new.from_date.should == nil
      end

      it "should be based on time" do
        DateRange.new(:from => EntryDate.new(:year => 2010)).from_date.to_s.should == Time.parse("2010-01-01 00:00:00").to_s
      end
      
      it "should be based on end_of time as-is for exclusive" do
        DateRange.new(:from => EntryDate.new(:year => 2009), :format => :exclusive).from_date.to_s.should == Time.parse("2009-12-31 23:59:59").to_s
        DateRange.new(:from => EntryDate.new(:year => 2009, :month => 2), :format => :exclusive).from_date.to_s.should == Time.parse("2009-02-28 23:59:59").to_s
        DateRange.new(:from => EntryDate.new(:year => 2009, :month => 2, :day => 15), :format => :exclusive).from_date.to_s.should == Time.parse("2009-02-15 23:59:59").to_s
      end

      it "should handle fixed points" do
        DateRange.new(:from => EntryDate.new(:year => 2009), :to => nil, :format => :fixed_point ).from_date.to_s.should == Time.parse("2009-01-01 00:00:00").to_s
        DateRange.new(:from => EntryDate.new(:year => 2009, :month => 10, :quarter => 4), :to => nil, :format => :fixed_point ).from_date.to_s.should == Time.parse("2009-10-01 00:00:00").to_s
        DateRange.new(:from => EntryDate.new(:year => 2009, :month => 10, :day => 2, :week => 39), :to => nil, :format => :fixed_point ).from_date.to_s.should == Time.parse("2009-09-28 00:00:00").to_s
        DateRange.new(:from => EntryDate.new(:year => 2009, :month => 10), :to => nil, :format => :fixed_point ).from_date.to_s.should == Time.parse("2009-10-01 00:00:00").to_s
        DateRange.new(:from => EntryDate.new(:year => 2009, :month => 10, :day => 3), :to => nil, :format => :fixed_point ).from_date.to_s.should == Time.parse("2009-10-03 00:00:00").to_s
        DateRange.new(:from => nil, :to => nil, :format => :fixed_point ).from_date.should == nil
      end
      
    end

    describe "#to_date" do
      it "should handle nil" do
        DateRange.new.to_date.should == nil
      end

      it "should be based on time as-is for exclusive" do
        DateRange.new(:to => EntryDate.new(:year => 2009), :format => :exclusive).to_date.to_s.should == Time.parse("2009-01-01 00:00:00").to_s
      end

      it "should be based on end_of time as-is for inclusive" do
        DateRange.new(:to => EntryDate.new(:year => 2009), :format => :inclusive).to_date.to_s.should == Time.parse("2009-12-31 23:59:59").to_s
        DateRange.new(:to => EntryDate.new(:year => 2009, :month => 2), :format => :inclusive).to_date.to_s.should == Time.parse("2009-02-28 23:59:59").to_s
        DateRange.new(:to => EntryDate.new(:year => 2009, :month => 2, :day => 15), :format => :inclusive).to_date.to_s.should == Time.parse("2009-02-15 23:59:59").to_s
      end

      it "should handle fixed points" do
        DateRange.new(:from => EntryDate.new(:year => 2009), :to => nil, :format => :fixed_point ).to_date.to_s.should == Time.parse("2009-12-31 23:59:59").to_s
        DateRange.new(:from => EntryDate.new(:year => 2009, :month => 10), :to => nil, :format => :fixed_point ).to_date.to_s.should == Time.parse("2009-10-31 23:59:59").to_s
        DateRange.new(:from => EntryDate.new(:year => 2009, :month => 10, :quarter => 4), :to => nil, :format => :fixed_point ).to_date.to_s.should == Time.parse("2009-12-31 23:59:59").to_s
        DateRange.new(:from => EntryDate.new(:year => 2009, :month => 10, :day => 2, :week => 39), :to => nil, :format => :fixed_point ).to_date.to_s.should == Time.parse("2009-10-04 23:59:59").to_s
        DateRange.new(:from => EntryDate.new(:year => 2009, :month => 10, :day => 3), :to => nil, :format => :fixed_point ).to_date.to_s.should == Time.parse("2009-10-03 23:59:59").to_s

        DateRange.new(:from => nil, :to => nil, :format => :fixed_point ).to_date.should == nil
      end

    end    
    
    describe "#to_sql" do
    
      before(:each) do
        @date1 = EntryDate.new(:year => 2010, :month => 10)
        @date2 = EntryDate.new(:year => 2011, :month => 3)
      end
      
      it "should support an empty date range" do
        DateRange.new.to_sql.should == "1=1"
      end
    
      it "should support from, inclusive" do
        DateRange.new(:from => @date1, :format => :inclusive).to_sql.should == "occurred_at >= '2010-10-01 00:00:00'"
      end
    
      it "should support from, exclusive" do
        DateRange.new(:from => @date1, :format => :exclusive).to_sql.should == "occurred_at > '2010-10-31 23:59:59'"
      end
    
      it "should support from, fixed_point, month" do
        DateRange.new(:from => @date1, :format => :fixed_point).to_sql.should == "(year=2010 and month=10)"
      end

      it "should support from, fixed_point, quarter" do
        quarter = EntryDate.new(:year => 2010, :month => 3, :quarter => 1)
        DateRange.new(:from => quarter, :format => :fixed_point).to_sql.should == "(year=2010 and quarter=1)"
      end

      it "should support from, fixed_point, week" do
        week = EntryDate.new(:year => 2010, :month => 1, :day => 15, :week => 2)
        DateRange.new(:from => week, :format => :fixed_point).to_sql.should == "(year=2010 and week=2)"
      end

      it "should support from, fixed_point, last week of year" do
        week = EntryDate.new(:year => 2010, :month => 12, :day => 30, :week => 52)
        DateRange.new(:from => week, :format => :fixed_point).to_sql.should == "((year=2010 and week=52) or (year=2011 and week=-1))"
      end

      it "should support from, fixed_point, first week of year" do
        week = EntryDate.new(:year => 2011, :month => 1, :day => 1, :week => -1)
        DateRange.new(:from => week, :format => :fixed_point).to_sql.should == "((year=2010 and week=52) or (year=2011 and week=-1))"
      end

      it "should support to, inclusive" do
        DateRange.new(:to => @date1, :format => :inclusive).to_sql.should == "occurred_at <= '2010-10-31 23:59:59'"
      end
    
      it "should support to, exclusive" do
        DateRange.new(:to => @date1, :format => :exclusive).to_sql.should == "occurred_at < '2010-10-01 00:00:00'"
      end

      it "should not support to, fixed_point" do
        DateRange.new(:to => @date1, :format => :fixed_point).to_sql.should == "1=1"
      end

      it "should support to and from, inclusive" do
        DateRange.new(:from => @date1, :to => @date2, :format => :inclusive).to_sql.should == "(occurred_at >= '2010-10-01 00:00:00' and occurred_at <= '2011-03-31 23:59:59')"
      end
    
      it "should support to and from, exclusive" do
        DateRange.new(:from => @date1, :to => @date2, :format => :exclusive).to_sql.should == "(occurred_at > '2010-10-31 23:59:59' and occurred_at < '2011-03-01 00:00:00')"
      end

      it "should not support to and from fixed_point" do
        DateRange.new(:to => @date1, :format => :fixed_point).to_sql.should == "1=1"
      end

    end
    
    
  end
end