require 'spec_helper'

module Appstats
  describe Benchmarker do

    before(:each) do
      @redis = InmemoryRedis.new
      @benchmarker = Benchmarker.new(:redis => @redis) 
    end

    describe "#initialize" do
      
      it "should default to redis" do
        Benchmarker.new.redis.should_not == nil
      end

      it "should be settable" do
        @benchmarker.redis.should == @redis
      end
      
    end
    
    describe "measure" do
      
      it "x" do
        time = @benchmarker.measure("BuildDuration","FooBar") do
          x = 10
        end
        @redis.scard("benchmarks").should == 1
        @redis.scard("benchmarks:BuildDuration").should == 1
        @redis.lrange("benchmarks:BuildDuration:FooBar",0,-1).should == [time.real]
      end
      
    end
    
    describe "record" do
      
      it "should track the title, legend, and point" do
        @benchmarker.record("BuildDuration","Appstats","15")
        @redis.scard("benchmarks").should == 1
        @redis.scard("benchmarks:BuildDuration").should == 1
        @redis.lrange("benchmarks:BuildDuration:Appstats",0,-1).should == ["15"]

        @benchmarker.record("BuildDuration","Appstats","20")
        @redis.lrange("benchmarks:BuildDuration:Appstats",0,-1).should == ["15","20"]

      end
      
    end
    
  end
end