require 'spec_helper'

module Appstats
  describe EntryDate do

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
      
      it "should accept garbage input" do
        EntryDate.parse("1234asdf1234 1234fds123").should == EntryDate.new
      end

    
    end

  end
end