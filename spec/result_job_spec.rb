require 'spec_helper'

module Appstats
  describe ResultJob do

    before(:each) do
      @result_job = Appstats::ResultJob.new
      @lasts_monday = Time.parse('2010-09-13 23:15:20')
      @monday = Time.parse('2010-09-20 23:15:20')
      @tuesday = Time.parse('2010-09-21 23:15:20')
      @wednesday = Time.parse('2010-09-22 23:15:20')
      Time.stub!(:now).and_return(@tuesday)
    end

    describe "#initialize" do
    
      it "should set attributes to nil" do
        @result_job.name.should == nil
        @result_job.frequency.should == nil
        @result_job.status.should == nil
        @result_job.query.should == nil
        @result_job.last_run_at.should == nil
      end
    
      it "should set on constructor" do
        result = Appstats::ResultJob.new(:name => 'a', :frequency => 'b', :status => 'c', :query => 'd', :last_run_at => Time.parse("2010-02-03"))
        result.name.should == 'a'
        result.frequency.should == 'b'
        result.status.should == 'c'
        result.query.should == 'd'
        result.last_run_at.to_s.should == Time.parse("2010-02-03").to_s
      end
    
    end
    
    describe "#should_run" do
      
      it "should be true if never run before" do
        @result_job.frequency = "yearly"
        @result_job.should_run.should == true
      end
      
      it "should be false if unknown frequency" do
        @result_job.should_run.should == false
      end

      describe "once" do

        before(:each) do
          @result_job.frequency = "once"
        end
        
        it "should run if not run yet" do
          @result_job.should_run.should == true
        end

        it "should not run if already run" do
          @result_job.last_run_at = Time.parse('2010-09-22')
          @result_job.should_run.should == false
        end
      end
      
      describe "daily" do
        
        before(:each) do
          @result_job.frequency = "daily"
        end
        
        it "should not run if today" do
          @result_job.last_run_at = Time.parse('2010-09-21')
          @result_job.should_run.should == false
        end

        it "should not run if tomorrow" do
          @result_job.last_run_at = Time.parse('2010-09-22')
          @result_job.should_run.should == false
        end

        it "should run if two days ago" do
          @result_job.last_run_at = Time.parse('2010-09-20')
          @result_job.should_run.should == true
        end

        it "should run if more than 2 days ago" do
          @result_job.last_run_at = Time.parse('2010-09-19')
          @result_job.should_run.should == true

          @result_job.last_run_at = Time.parse('2010-09-18')
          @result_job.should_run.should == true
        end
      end      
      
      describe "weekly" do
        
        before(:each) do
          @result_job.frequency = "weekly"
        end
        
        it "should not run if today" do
          @result_job.last_run_at = Time.parse('2010-09-21')
          @result_job.should_run.should == false
        end

        it "should not run if tomorrow" do
          @result_job.last_run_at = Time.parse('2010-09-22')
          @result_job.should_run.should == false
        end

        it "should not run if within same week" do
          @result_job.last_run_at = Time.parse('2010-09-20')
          @result_job.should_run.should == false

          Time.stub!(:now).and_return(@wednesday)
          @result_job.should_run.should == false
        end

        it "should run if exactly a week ago" do
          @result_job.last_run_at = @last_monday
          Time.stub!(:now).and_return(@monday)
          @result_job.should_run.should == true
        end

        it "should run if more than 1 week ago (based on monday start time)" do
          @result_job.last_run_at = Time.parse('2010-09-19')
          @result_job.should_run.should == true

          @result_job.last_run_at = Time.parse('2010-09-18')
          @result_job.should_run.should == true
        end
      end      
      
      describe "monthly" do
        
        before(:each) do
          @result_job.frequency = "monthly"
        end
        
        it "should not run if today" do
          @result_job.last_run_at = Time.parse('2010-09-21')
          @result_job.should_run.should == false
        end

        it "should not run if tomorrow" do
          @result_job.last_run_at = Time.parse('2010-09-22')
          @result_job.should_run.should == false
        end

        it "should not run if within same month" do
          @result_job.last_run_at = Time.parse('2010-09-01')
          @result_job.should_run.should == false
        end

        it "should run if exactly a month ago" do
          @result_job.last_run_at = Time.parse('2010-08-01')
          Time.stub!(:now).and_return(Time.parse('2010-09-01'))
          @result_job.should_run.should == true
        end

        it "should run if more than 1 month ago" do
          @result_job.last_run_at = Time.parse('2010-08-01')
          @result_job.should_run.should == true
        end
      end      
      
      describe "quarterly" do
        
        before(:each) do
          @result_job.frequency = "quarterly"
        end
        
        it "should not run if today" do
          @result_job.last_run_at = Time.parse('2010-09-21')
          @result_job.should_run.should == false
        end

        it "should not run if tomorrow" do
          @result_job.last_run_at = Time.parse('2010-09-22')
          @result_job.should_run.should == false
        end

        it "should not run if within same quarter" do
          @result_job.last_run_at = Time.parse('2010-07-03')
          @result_job.should_run.should == false
        end

        it "should run if exactly a quarter ago" do
          @result_job.last_run_at = Time.parse('2010-07-01')
          Time.stub!(:now).and_return(Time.parse('2010-10-01'))
          @result_job.should_run.should == true
        end

        it "should run if more than a quarter ago" do
          @result_job.last_run_at = Time.parse('2010-06-15')
          @result_job.should_run.should == true
        end
      end      
      
      describe "yearly" do
        
        before(:each) do
          @result_job.frequency = "yearly"
        end
        
        it "should not run if today" do
          @result_job.last_run_at = Time.parse('2010-09-21')
          @result_job.should_run.should == false
        end

        it "should not run if tomorrow" do
          @result_job.last_run_at = Time.parse('2010-09-22')
          @result_job.should_run.should == false
        end

        it "should not run if within same year" do
          @result_job.last_run_at = Time.parse('2010-02-03')
          @result_job.should_run.should == false
        end

        it "should run if exactly a year ago" do
          @result_job.last_run_at = Time.parse('2010-01-01')
          Time.stub!(:now).and_return(Time.parse('2011-01-01'))
          @result_job.should_run.should == true
        end

        it "should run if more than a year ago" do
          @result_job.last_run_at = Time.parse('2009-06-15')
          @result_job.should_run.should == true
        end
      end      
    end
    
    
    describe "#==" do
      
      it "should be equal on all attributes" do
        result = Appstats::ResultJob.new(:name => 'a', :frequency => 'b', :status => 'c', :query => 'd', :last_run_at => Time.parse("2010-02-03"))
        same_result = Appstats::ResultJob.new(:name => 'a', :frequency => 'b', :status => 'c', :query => 'd', :last_run_at => Time.parse("2010-02-03"))
        (result == same_result).should == true
      end
      
      it "should be not equal if diferent attributes" do
        result = Appstats::ResultJob.new(:name => 'a', :frequency => 'b', :status => 'c', :query => 'd', :last_run_at => Time.parse("2010-02-03"))
        
        [:name,:frequency,:status,:query,:last_run_at].each do |attr|
          different_result = Appstats::ResultJob.new(:name => 'a', :frequency => 'b', :status => 'c', :query => 'd', :last_run_at => Time.parse("2010-02-03"))

          if [:last_run_at].include?(attr)
            different_result.send("#{attr}=",Time.parse("2011-01-02"))
          else
            different_result.send("#{attr}=","XXX")
          end
          
          different_result.should_not == result
        end
      end

    end
    
  end
end