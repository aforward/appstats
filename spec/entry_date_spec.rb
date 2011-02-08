require 'spec_helper'

module Appstats
  describe EntryDate do

    before(:each) do
      @time = Time.parse('2010-01-15 10:20:30') # Friday
      Time.stub!(:now).and_return(@time)
    end

    describe "#initialize" do
      
      it "should understand year, month, day, hour, min, sec" do
        date = EntryDate.new(:year => 2010, :month => 1, :day => 2, :hour => 3, :min => 4, :sec => 5)
        date.year.should == 2010
        date.month.should == 1
        date.day.should == 2
        date.hour.should == 3
        date.min.should == 4
        date.sec.should == 5
      end
      
      it "should understand equality" do
        date = EntryDate.new(:year => 2010, :month => 1, :day => 2, :hour => 3, :min => 4, :sec => 5)
        same_date = EntryDate.new(:year => 2010, :month => 1, :day => 2, :hour => 3, :min => 4, :sec => 5)
        another_date = EntryDate.new(:year => 2011, :month => 1, :day => 2, :hour => 3, :min => 4, :sec => 5)
        
        date.should == date
        date.should == same_date
        date.should_not == another_date
      end
      
      
    end
    
    describe "#to_time" do

      it "should handle full dates" do
        EntryDate.new(:year => 2010, :month => 1, :day => 2, :hour => 3, :min => 4, :sec => 5).to_time.should == Time.parse("2010-01-02 03:04:05")
      end

      it "should handle partial dates" do
        EntryDate.new(:year => 2010, :month => 2).to_time.should == Time.parse("2010-02-01 00:00:00")
      end

      it "should handle now" do
        EntryDate.new.to_time.should == Time.now
      end

      
    end
    

    describe "#to_s" do
      it "should handle full dates" do
        EntryDate.new(:year => 2010, :month => 1, :day => 2, :hour => 3, :min => 4, :sec => 5).to_s.should == "2010-01-02 03:04:05"
      end

      it "should handle partial dates" do
        EntryDate.new(:year => 2010, :month => 1).to_s.should == "2010-01"
      end
    end
    
    describe "#end_of_week" do
      it "should return the same 'level' data points" do
        now = EntryDate.new(:year => 2010, :month => 1, :day => 5, :hour => 10) # tuesday
        expected = EntryDate.new(:year => 2010, :month => 1, :day => 10, :hour => 10)
        now.end_of_week.should == expected
      end
    end

    describe "#parse" do

      it "should deal with nil" do
         EntryDate.parse(nil).should == EntryDate.new
         EntryDate.parse("").should == EntryDate.new
      end
      
      it "should undestand years" do
        EntryDate.parse("2010").should == EntryDate.new(:year => 2010)
        EntryDate.parse("2011").should == EntryDate.new(:year => 2011)
      end
      
      it "should understand month, year" do
        EntryDate.parse("February, 2010").should == EntryDate.new(:year => 2010, :month => 2)
        EntryDate.parse("Mar, 2011").should == EntryDate.new(:year => 2011, :month => 3)
      end

      it "should understand YYYY-mm-dd" do
        EntryDate.parse("2010-04-25").should == EntryDate.new(:year => 2010, :month => 4, :day => 25)
        EntryDate.parse("2011-05-15").should == EntryDate.new(:year => 2011, :month => 5, :day => 15)
      end

      it "should understand YYYY-mm-dd HH:MM:SS" do
        EntryDate.parse("2010-04-25 10:11:12").should == EntryDate.new(:year => 2010, :month => 4, :day => 25, :hour => 10, :min => 11, :sec => 12)
      end

      it "should understand YTD" do
        EntryDate.parse("YTD").should == EntryDate.new(:year => 2010)
        EntryDate.parse("ytd").should == EntryDate.new(:year => 2010)
      end

      it "should understand yesterday" do
        EntryDate.parse("yesterday").should == EntryDate.new(:year => 2010, :month => 1, :day => 14)
      end

      it "should understand today" do
        EntryDate.parse("today").should == EntryDate.new(:year => 2010, :month => 1, :day => 15)
      end
      
      it "should understand last year" do
        EntryDate.parse("last year").should == EntryDate.new(:year => 2009)
      end

      it "should understand last month" do
        EntryDate.parse("last month").should == EntryDate.new(:year => 2009, :month => 12)
      end

      it "should understand last week" do
        EntryDate.parse("last week").should == EntryDate.new(:year => 2010, :month => 1, :day => 4)
      end

      it "should understand last day" do
        EntryDate.parse("last day").should == EntryDate.new(:year => 2010, :month => 1, :day => 14)
      end

      it "should understand previous year" do
        EntryDate.parse("previous year").should == EntryDate.new(:year => 2009)
      end

      it "should understand previous month" do
        EntryDate.parse("previous month").should == EntryDate.new(:year => 2009, :month => 12)
      end

      it "should understand previous week" do
        EntryDate.parse("previous week").should == EntryDate.new(:year => 2010, :month => 1, :day => 4)
      end

      it "should understand previous day" do
        EntryDate.parse("previous day").should == EntryDate.new(:year => 2010, :month => 1, :day => 14)
      end

      it "should understand this year" do
        EntryDate.parse("this year").should == EntryDate.new(:year => 2010)
      end

      it "should understand this month" do
        EntryDate.parse("this month").should == EntryDate.new(:year => 2010, :month => 1)
      end

      it "should understand this week" do
        EntryDate.parse("this week").should == EntryDate.new(:year => 2010, :month => 1, :day => 11)
      end

      it "should understand this day" do
        EntryDate.parse("this day").should == EntryDate.new(:year => 2010, :month => 1, :day => 15)
      end

      it "should understand last X years" do
        EntryDate.parse("last 1 year").should == EntryDate.new(:year => 2010)
        EntryDate.parse("last 2 years").should == EntryDate.new(:year => 2009)
        EntryDate.parse("last 3 years").should == EntryDate.new(:year => 2008)
      end

      it "should understand last X months" do
        EntryDate.parse("last 1 month").should == EntryDate.new(:year => 2010, :month => 1)
        EntryDate.parse("last 2 months").should == EntryDate.new(:year => 2009, :month => 12)
        EntryDate.parse("last 3 months").should == EntryDate.new(:year => 2009, :month => 11)
      end

      it "should understand last X weeks" do
        EntryDate.parse("last 1 week").should == EntryDate.new(:year => 2010, :month => 1, :day => 11)
        EntryDate.parse("last 2 weeks").should == EntryDate.new(:year => 2010, :month => 1, :day => 4)
        EntryDate.parse("last 3 weeks").should == EntryDate.new(:year => 2009, :month => 12, :day => 28)
      end

      it "should understand last X days" do
        EntryDate.parse("last 1 day").should == EntryDate.new(:year => 2010, :month => 1, :day => 15)
        EntryDate.parse("last 2 days").should == EntryDate.new(:year => 2010, :month => 1, :day => 14)
        EntryDate.parse("last 3 days").should == EntryDate.new(:year => 2010, :month => 1, :day => 13)
      end

      it "should understand previous X years" do
        EntryDate.parse("previous 1 year").should == EntryDate.new(:year => 2009)
        EntryDate.parse("previous 2 years").should == EntryDate.new(:year => 2008)
        EntryDate.parse("previous 3 years").should == EntryDate.new(:year => 2007)
      end

      it "should understand previous X months" do
        EntryDate.parse("previous 1 month").should == EntryDate.new(:year => 2009, :month => 12)
        EntryDate.parse("previous 2 months").should == EntryDate.new(:year => 2009, :month => 11)
        EntryDate.parse("previous 3 months").should == EntryDate.new(:year => 2009, :month => 10)
      end

      it "should understand previous X weeks" do
        EntryDate.parse("previous 1 week").should == EntryDate.new(:year => 2010, :month => 1, :day => 4)
        EntryDate.parse("previous 2 weeks").should == EntryDate.new(:year => 2009, :month => 12, :day => 28)
        EntryDate.parse("previous 3 weeks").should == EntryDate.new(:year => 2009, :month => 12, :day => 21)
      end

      it "should understand previous X days" do
        EntryDate.parse("previous 1 day").should == EntryDate.new(:year => 2010, :month => 1, :day => 14)
        EntryDate.parse("previous 2 days").should == EntryDate.new(:year => 2010, :month => 1, :day => 13)
        EntryDate.parse("previous 3 days").should == EntryDate.new(:year => 2010, :month => 1, :day => 12)
      end

      it "should accept garbage input" do
        EntryDate.parse("1234asdf1234 1234fds123").should == EntryDate.new
      end
      
      
    end

  end
end