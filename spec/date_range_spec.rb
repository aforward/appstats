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

      
      it "should understand before" do
        range = DateRange.parse("  before Mar, 2010  ")
        range.should == DateRange.new(:to => EntryDate.new(:year => 2010, :month => 3), :from => nil, :format => "exclusive" )
      end

      it "should understand after" do
        range = DateRange.parse("  after Mar, 2010  ")
        range.should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 3), :to => nil, :format => "exclusive" )
      end
      
      it "should understand YTD, today" do
        DateRange.parse("  YTD  ").should == DateRange.new(:from => EntryDate.new(:year => 2010), :to => nil, :format => "fixed_point" )
        DateRange.parse("  today  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 15), :to => nil, :format => "fixed_point" )
      end

      it "should understand yesterday" do
        DateRange.parse("  yesterday  ").should == DateRange.new(:from => EntryDate.new(:year => 2010, :month => 1, :day => 14), :to => nil, :format => "fixed_point" )
      end
      
    end
    
    
  end
end