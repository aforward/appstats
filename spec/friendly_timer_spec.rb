require 'spec_helper'

module Appstats
  describe FriendlyTimer do

    before(:each) do
      @before_now = Time.parse("2010-09-21 10:11:10")
      @now = Time.parse("2010-09-21 10:11:12")
      Time.stub!(:now).and_return(@now)
      @obj = Appstats::FriendlyTimer.new
    end
    
    describe "#initialize" do
      
      it "should set duration to nil" do
        @obj.duration.should == nil
        @obj.start_time.should == @now
        @obj.stop_time.should == nil
      end

      it "should support constructor values" do
        obj = Appstats::FriendlyTimer.new(:duration => 12.34)
        obj.duration.should == 12.34
      end
      
    end
    
    describe "#start" do
      
      it "should set start_time to now" do
        @obj.start.should == @now
        @obj.start_time.should == @now
      end
      
    end

    describe "#stop" do
      
      it "should set stop_time to now" do
        @obj.stop.should == @now
        @obj.stop_time.should == @now
      end

      it "should leave duration alone if start time nil" do
        @obj.start_time = nil
        @obj.stop
        @obj.duration.should == nil
      end
      
      it "should update the duration if start time set" do
        Time.stub!(:now).and_return(@before_now)
        @obj.start
        Time.stub!(:now).and_return(@now)
        @obj.stop
        @obj.duration.should == 2
      end
      
    end

    describe "#calculate_duration_to_s" do
      
      it "should support nil" do
        Appstats::FriendlyTimer.calculate_duration_to_s(nil).should == "N/A"
      end

      it "only two decimal places" do
        Appstats::FriendlyTimer.calculate_duration_to_s(19.342).should == '19.34 seconds'
      end

      it "milliseconds" do
        Appstats::FriendlyTimer.calculate_duration_to_s(0.34).should == '340 milliseconds'
      end

      it "seconds" do
        Appstats::FriendlyTimer.calculate_duration_to_s(9.34).should == '9.34 seconds'
      end

      it "minutes" do
        Appstats::FriendlyTimer.calculate_duration_to_s(1.12*60).should == '1.12 minutes'
      end

      it "hours" do
        Appstats::FriendlyTimer.calculate_duration_to_s(1.5*60*60).should == '1.5 hours'
      end

      it "days" do
        Appstats::FriendlyTimer.calculate_duration_to_s(2.8*60*60*24).should == '2.8 days'
      end

      it "years" do
        Appstats::FriendlyTimer.calculate_duration_to_s(9.8*60*60*24*365).should == '9.8 years'
      end

      it "second" do
        Appstats::FriendlyTimer.calculate_duration_to_s(1).should == '1 second'
      end

      it "minute" do
        Appstats::FriendlyTimer.calculate_duration_to_s(60).should == '1 minute'
      end

      it "hour" do
        Appstats::FriendlyTimer.calculate_duration_to_s(1*60*60).should == '1 hour'
      end

      it "day" do
        Appstats::FriendlyTimer.calculate_duration_to_s(1*60*60*24).should == '1 day'
      end

      it "year" do
        Appstats::FriendlyTimer.calculate_duration_to_s(1*60*60*24*365).should == '1 year'
      end      
    end

    describe "#duration_to_s" do
      
      it "should support nil" do
        obj = Appstats::FriendlyTimer.new
        obj.duration_to_s.should == "N/A"
      end
      
      it "only two decimal places" do
        Appstats::FriendlyTimer.new(:duration => 19.342).duration_to_s.should == '19.34 seconds'
      end
      
      it "milliseconds" do
        Appstats::FriendlyTimer.new(:duration => 0.34).duration_to_s.should == '340 milliseconds'
      end

      it "seconds" do
        Appstats::FriendlyTimer.new(:duration => 9.34).duration_to_s.should == '9.34 seconds'
      end

      it "minutes" do
        Appstats::FriendlyTimer.new(:duration => 1.12*60).duration_to_s.should == '1.12 minutes'
      end

      it "hours" do
        Appstats::FriendlyTimer.new(:duration => 1.5*60*60).duration_to_s.should == '1.5 hours'
      end

      it "days" do
        Appstats::FriendlyTimer.new(:duration => 2.8*60*60*24).duration_to_s.should == '2.8 days'
      end

      it "years" do
        Appstats::FriendlyTimer.new(:duration => 9.8*60*60*24*365).duration_to_s.should == '9.8 years'
      end

      it "second" do
        Appstats::FriendlyTimer.new(:duration => 1).duration_to_s.should == '1 second'
      end

      it "minute" do
        Appstats::FriendlyTimer.new(:duration => 60).duration_to_s.should == '1 minute'
      end

      it "hour" do
        Appstats::FriendlyTimer.new(:duration => 1*60*60).duration_to_s.should == '1 hour'
      end

      it "day" do
        Appstats::FriendlyTimer.new(:duration => 1*60*60*24).duration_to_s.should == '1 day'
      end

      it "year" do
        Appstats::FriendlyTimer.new(:duration => 1*60*60*24*365).duration_to_s.should == '1 year'
      end


      
    end
  end
end