require 'spec_helper'

module Appstats
  describe ResultJob do

    before(:each) do
      @result_job = Appstats::ResultJob.new
      Time.stub!(:now).and_return(Time.parse('2010-09-21 23:15:20'))
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