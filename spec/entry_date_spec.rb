require 'spec_helper'

module Appstats
  describe EntryDate do

    before(:each) do
      @time = Time.parse('2010-01-15 10:20:30') # Friday
      Time.stub!(:now).and_return(@time)
    end

    describe "#initialize" do
      
      it "should understand year, month, day, hour, min, sec" do
        date = EntryDate.new(:year => 2010, :month => 1, :day => 2, :hour => 3, :min => 4, :sec => 5, :week => 6, :quarter => 7)
        date.year.should == 2010
        date.month.should == 1
        date.day.should == 2
        date.hour.should == 3
        date.min.should == 4
        date.sec.should == 5
        date.week.should == 6
        date.quarter.should == 7
      end
  
    end
    
    describe "#==" do
      
      it "should be equal on all attributes" do
        date = EntryDate.new(:year => 2010, :month => 1, :day => 2, :hour => 3, :min => 4, :sec => 5, :week => 6, :quarter => 7)
        same_date = EntryDate.new(:year => 2010, :month => 1, :day => 2, :hour => 3, :min => 4, :sec => 5, :week => 6, :quarter => 7)
        date.should == date
        date.should == same_date
      end
      
      it "should be not equal if diferent attributes" do
        date = EntryDate.new(:year => 2010, :month => 1, :day => 2, :hour => 3, :min => 4, :sec => 5, :week => 6, :quarter => 7)
        
        [:year,:month,:day,:hour,:min,:sec,:week,:quarter].each do |attr|
          different_date = EntryDate.new(:year => 2010, :month => 1, :day => 2, :hour => 3, :min => 4, :sec => 5, :week => 6, :quarter => 7)
          different_date.send("#{attr}=",99)
          different_date.should_not == date
        end
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
      
      it "should handle end_of" do
        EntryDate.new(:year => 2009).to_time(:end).to_s.should == Time.parse("2009-12-31 23:59:59").to_s
        EntryDate.new(:year => 2009, :month => 2).to_time(:end).to_s.should == Time.parse("2009-02-28 23:59:59").to_s
        EntryDate.new(:year => 2009, :month => 2, :day => 15).to_time(:end).to_s.should == Time.parse("2009-02-15 23:59:59").to_s
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
        expected = EntryDate.new(:year => 2010, :month => 1, :day => 10, :hour => 10, :week => 1)
        now.end_of_week.should == expected
      end
    end

    describe "#end_of_quarter" do
      it "should return the same 'level' data points" do
        now = EntryDate.new(:year => 2010, :month => 1, :day => 5, :hour => 10)
        expected = EntryDate.new(:year => 2010, :month => 3, :quarter => 1)
        now.end_of_quarter.should == expected
      end

      it "should return quarter" do
        now = EntryDate.new(:year => 2010, :month => 1, :quarter => 1)
        expected = EntryDate.new(:year => 2010, :month => 3, :quarter => 1)
        now.end_of_quarter.should == expected
      end

    end

    describe "#calculate_quarter_of" do
      
      it "should handle nil" do
        EntryDate.calculate_quarter_of(nil).should == nil
      end
      
      it "should be 1 for jan/feb/mar" do
        EntryDate.calculate_quarter_of(Time.parse("2011-01-01")).should == 1
        EntryDate.calculate_quarter_of(Time.parse("2011-02-15")).should == 1
        EntryDate.calculate_quarter_of(Time.parse("2011-03-31")).should == 1
      end

      it "should be 2 for apr/may/jun" do
        EntryDate.calculate_quarter_of(Time.parse("2011-04-01")).should == 2
        EntryDate.calculate_quarter_of(Time.parse("2011-05-15")).should == 2
        EntryDate.calculate_quarter_of(Time.parse("2011-06-30")).should == 2
      end

      it "should be 3 for jul/aug/sep" do
        EntryDate.calculate_quarter_of(Time.parse("2011-07-01")).should == 3
        EntryDate.calculate_quarter_of(Time.parse("2011-08-15")).should == 3
        EntryDate.calculate_quarter_of(Time.parse("2011-09-30")).should == 3
      end

      it "should be 4 for oct/nov/dec" do
        EntryDate.calculate_quarter_of(Time.parse("2011-10-01")).should == 4
        EntryDate.calculate_quarter_of(Time.parse("2011-11-15")).should == 4
        EntryDate.calculate_quarter_of(Time.parse("2011-12-31")).should == 4
      end
      
      
    end

    describe "#calculate_quarter_of" do
      
      it "should handle nil" do
        EntryDate.calculate_quarter_of(nil).should == nil
      end
      
      it "should be 1 for jan/feb/mar" do
        EntryDate.calculate_quarter_of(Time.parse("2011-01-01")).should == 1
        EntryDate.calculate_quarter_of(Time.parse("2011-02-15")).should == 1
        EntryDate.calculate_quarter_of(Time.parse("2011-03-31")).should == 1
      end

      it "should be 2 for apr/may/jun" do
        EntryDate.calculate_quarter_of(Time.parse("2011-04-01")).should == 2
        EntryDate.calculate_quarter_of(Time.parse("2011-05-15")).should == 2
        EntryDate.calculate_quarter_of(Time.parse("2011-06-30")).should == 2
      end

      it "should be 3 for jul/aug/sep" do
        EntryDate.calculate_quarter_of(Time.parse("2011-07-01")).should == 3
        EntryDate.calculate_quarter_of(Time.parse("2011-08-15")).should == 3
        EntryDate.calculate_quarter_of(Time.parse("2011-09-30")).should == 3
      end

      it "should be 4 for oct/nov/dec" do
        EntryDate.calculate_quarter_of(Time.parse("2011-10-01")).should == 4
        EntryDate.calculate_quarter_of(Time.parse("2011-11-15")).should == 4
        EntryDate.calculate_quarter_of(Time.parse("2011-12-31")).should == 4
      end
      
      
    end

    describe "#calculate_week_of" do
      
      it "should handle nil" do
        EntryDate.calculate_week_of(nil).should == nil
      end
      
      it "should be -1 if jan 1 is not start of week" do
        EntryDate.calculate_week_of(Time.parse("2011-01-01")).should == -1
        EntryDate.calculate_week_of(Time.parse("2011-01-02")).should == -1
      end
      
      it "should be 1 for the first monday of the year" do
        EntryDate.calculate_week_of(Time.parse("2011-01-03")).should == 1
      end

      it "should be 1 if the first day is on a monday" do
        EntryDate.calculate_week_of(Time.parse("2018-01-01")).should == 1
      end

      it "should be X for the Xth monday of the year" do
        time = Time.parse("2011-01-03")
        1.upto(52).each do |offset|
          EntryDate.calculate_week_of(time).should == offset
          time = time.next_week
        end
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

      it "should understand last quarter" do
        EntryDate.parse("last quarter").should == EntryDate.new(:year => 2009, :month => 10, :quarter => 4)
      end

      it "should understand last month" do
        EntryDate.parse("last month").should == EntryDate.new(:year => 2009, :month => 12)
      end

      it "should understand last week" do
        EntryDate.parse("last week").should == EntryDate.new(:year => 2010, :month => 1, :day => 4, :week => 1)
      end

      it "should understand last day" do
        EntryDate.parse("last day").should == EntryDate.new(:year => 2010, :month => 1, :day => 14)
      end

      it "should understand previous year" do
        EntryDate.parse("previous year").should == EntryDate.new(:year => 2009)
      end

      it "should understand previous quarter" do
        EntryDate.parse("previous quarter").should == EntryDate.new(:year => 2009, :month => 10, :quarter => 4)
      end

      it "should understand previous month" do
        EntryDate.parse("previous month").should == EntryDate.new(:year => 2009, :month => 12)
      end

      it "should understand previous week" do
        EntryDate.parse("previous week").should == EntryDate.new(:year => 2010, :month => 1, :day => 4, :week => 1)
      end

      it "should understand previous day" do
        EntryDate.parse("previous day").should == EntryDate.new(:year => 2010, :month => 1, :day => 14)
      end

      it "should understand this year" do
        EntryDate.parse("this year").should == EntryDate.new(:year => 2010)
      end

      it "should understand this quarter" do
        EntryDate.parse("this quarter").should == EntryDate.new(:year => 2010, :month => 1, :quarter => 1)
      end

      it "should understand this month" do
        EntryDate.parse("this month").should == EntryDate.new(:year => 2010, :month => 1)
      end

      it "should understand this week" do
        EntryDate.parse("this week").should == EntryDate.new(:year => 2010, :month => 1, :day => 11, :week => 2)
      end

      it "should understand this day" do
        EntryDate.parse("this day").should == EntryDate.new(:year => 2010, :month => 1, :day => 15)
      end

      it "should understand last X years" do
        EntryDate.parse("last 1 year").should == EntryDate.new(:year => 2010)
        EntryDate.parse("last 2 years").should == EntryDate.new(:year => 2009)
        EntryDate.parse("last 3 years").should == EntryDate.new(:year => 2008)
      end

      it "should understand last X quarters" do
        EntryDate.parse("last 1 quarter").should == EntryDate.new(:year => 2010, :month => 1, :quarter => 1 )
        EntryDate.parse("last 2 quarters").should == EntryDate.new(:year => 2009, :month => 10, :quarter => 4)
        EntryDate.parse("last 3 quarters").should == EntryDate.new(:year => 2009, :month => 7, :quarter => 3)
      end


      it "should understand last X months" do
        EntryDate.parse("last 1 month").should == EntryDate.new(:year => 2010, :month => 1)
        EntryDate.parse("last 2 months").should == EntryDate.new(:year => 2009, :month => 12)
        EntryDate.parse("last 3 months").should == EntryDate.new(:year => 2009, :month => 11)
      end

      it "should understand last X weeks" do
        EntryDate.parse("last 1 week").should == EntryDate.new(:year => 2010, :month => 1, :day => 11, :week => 2)
        EntryDate.parse("last 2 weeks").should == EntryDate.new(:year => 2010, :month => 1, :day => 4, :week => 1)
        EntryDate.parse("last 3 weeks").should == EntryDate.new(:year => 2009, :month => 12, :day => 28, :week => 52)
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

      it "should understand previous X quarters" do
        EntryDate.parse("previous 1 quarter").should == EntryDate.new(:year => 2009, :month => 10, :quarter => 4)
        EntryDate.parse("previous 2 quarters").should == EntryDate.new(:year => 2009, :month => 7, :quarter => 3)
        EntryDate.parse("previous 3 quarters").should == EntryDate.new(:year => 2009, :month => 4, :quarter => 2)
      end

      it "should understand previous X months" do
        EntryDate.parse("previous 1 month").should == EntryDate.new(:year => 2009, :month => 12)
        EntryDate.parse("previous 2 months").should == EntryDate.new(:year => 2009, :month => 11)
        EntryDate.parse("previous 3 months").should == EntryDate.new(:year => 2009, :month => 10)
      end

      it "should understand previous X weeks" do
        EntryDate.parse("previous 1 week").should == EntryDate.new(:year => 2010, :month => 1, :day => 4, :week => 1)
        EntryDate.parse("previous 2 weeks").should == EntryDate.new(:year => 2009, :month => 12, :day => 28, :week => 52)
        EntryDate.parse("previous 3 weeks").should == EntryDate.new(:year => 2009, :month => 12, :day => 21, :week => 51)
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