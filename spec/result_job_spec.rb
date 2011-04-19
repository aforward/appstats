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
        @result_job.query_type.should == nil
      end
    
      it "should set on constructor" do
        result_job = Appstats::ResultJob.new(:name => 'a', :frequency => 'b', :status => 'c', :query => 'd', :last_run_at => Time.parse("2010-02-03"), :query_type => 'e')
        result_job.name.should == 'a'
        result_job.frequency.should == 'b'
        result_job.status.should == 'c'
        result_job.query.should == 'd'
        result_job.last_run_at.to_s.should == Time.parse("2010-02-03").to_s
        result_job.query_type.should == 'e'
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
    
    describe "#require_third_party_queries" do


      it "should ignore invalid input" do
        Appstats.should_receive(:log).with(:info, "Please specify the third party query ':path'.")
        Appstats::ResultJob.require_third_party_queries([ { :blah => '/does/not/exist.rb'} ])
      end

      it "should ignore nill input" do
        Appstats.should_receive(:log).with(:info, "No third party query provided.")
        Appstats::ResultJob.require_third_party_queries(nil)
      end
      
      it "should ignore invalid files" do
        File.exists?('/does/not/exist.rb').should == false
        Appstats.should_receive(:log).with(:info, "Unable to find third party query [/does/not/exist.rb].")
        Appstats::ResultJob.require_third_party_queries([ { :path => '/does/not/exist.rb'} ])
      end
      
      it "should load the file" do
        Object::const_defined?('UnloadedQuery').should == false
        Appstats.should_receive(:log).with(:info, "Loaded to third party query [#{File.dirname(__FILE__)}/../lib/appstats/test_unloaded_query.rb].")
        Appstats::ResultJob.require_third_party_queries([ { :path => "#{File.dirname(__FILE__)}/../lib/appstats/test_unloaded_query.rb"} ])
        Object::const_defined?('UnloadedQuery').should == true
      end
      
    end
    
    
    describe "#run" do
      
      before(:each) do
        Appstats::ResultJob.delete_all
        Appstats::Result.delete_all
        Appstats::Entry.delete_all
      end
      
      it "nothing to do" do
        Appstats::ResultJob.run.should == 0
      end

      it "should update job" do
        job1 = Appstats::ResultJob.create(:query => "# blahs", :frequency => "once")
        Appstats::ResultJob.run.should == 1
        
        job1.reload
        job1.last_run_at.to_s.should == @tuesday.to_s
      end

      it "should track the query_type" do
        job1 = Appstats::ResultJob.create(:query => "# blahs", :frequency => "once", :query_type => "Appstats::TestQuery")
        Appstats::ResultJob.run.should == 1
        result = Appstats::Result.last
        result.query.should == "# blahs"
        result.query_type.should == "Appstats::TestQuery"
      end

      
      it "should log when no queries" do
        Appstats.should_receive(:log).with(:info, "No result jobs to run.")
        Appstats::ResultJob.run.should == 0
      end      

      it "should ignore 'once' with a last_run_at date" do
        job1 = Appstats::ResultJob.create(:name => "x", :query => "# blahs", :frequency => "once", :last_run_at => Time.now)
        Appstats.should_receive(:log).with(:info, "No result jobs to run.")
        Appstats::ResultJob.run.should == 0
      end      
      
      it "should log which queries are run" do
        job1 = Appstats::ResultJob.create(:name => "x", :query => "# blahs", :frequency => "weekly", :last_run_at => Time.now)
        job2 = Appstats::ResultJob.create(:name => "y", :query => "# blahs where type=1", :frequency => "daily")

        Appstats.should_receive(:log).with(:info, "About to analyze 2 result job(s).")
        Appstats.should_receive(:log).with(:info, "  - Job x NOT run [ID #{job1.id}, FREQUENCY weekly, QUERY # blahs]")
        Appstats.should_receive(:log).with(:info, "  - Job y run [ID #{job2.id}, FREQUENCY daily, QUERY # blahs where type=1]")
        Appstats.should_receive(:log).with(:info, "Ran 1 query(ies).")
        
        Appstats::ResultJob.run.should == 1
      end
      
      it "should create results" do
        job1 = Appstats::ResultJob.create(:name => "x", :query => "# blahs", :frequency => "once")
        job2 = Appstats::ResultJob.create(:name => "y", :query => "# blahs where type=1", :frequency => "once")
        Appstats::Entry.create_from_logger("blahs", :type => "2")
        Appstats::Entry.create_from_logger("blahs", :type => "1")
        
        Appstats::ResultJob.run.should == 2
        
        all = Appstats::Result.all
        all.count.should == 2

        all[0].name.should == "x"
        all[1].name.should == "y"

        all[0].query.should == "# blahs"
        all[1].query.should == "# blahs where type=1"

        all[0].result_type.should == "result_job"
        all[1].result_type.should == "result_job"

        all[0].count.should == 2
        all[1].count.should == 1
      end
      
    end
    
  end
end