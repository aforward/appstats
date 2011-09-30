require 'spec_helper'

module Appstats
  describe InmemoryRedis do

    before(:each) do
      @redis = InmemoryRedis.new
    end

    describe "#sadd" do
      
      it "should add to the set" do
        @redis.sadd("benchmarks", "one").should == true
        @redis.scard("benchmarks").should == 1
      end
      
      it "should not allow duplicate" do
        @redis.sadd("benchmarks", "one").should == true
        @redis.scard("benchmarks").should == 1
        @redis.sadd("benchmarks", "one").should == false
        @redis.scard("benchmarks").should == 1
        @redis.sadd("benchmarks", "two").should == true
        @redis.scard("benchmarks").should == 2
      end
      
    end
    
    describe "#scard" do
      
      it "should handle nil" do
        @redis.scard(nil).should == 0
        @redis.scard("").should == 0
      end

      it "should handle unknown" do
        @redis.scard("blah").should == 0
      end

      it "should count" do
        @redis.scard("benchmarks").should == 0
        @redis.sadd "benchmarks", "one"
        @redis.scard("benchmarks").should == 1
        @redis.sadd "benchmarks", "two"
        @redis.scard("benchmarks").should == 2
      end

      
    end

    describe "#rpush" do
      
      it "should add the entry" do
        @redis.llen("x").should == 0
        @redis.rpush("x", "one").should == true
        @redis.llen("x").should == 1
      end
      
      it "should allow duplicates" do
        @redis.llen("x").should == 0
        @redis.rpush("x", "one").should == true
        @redis.rpush("x", "one").should == true
        @redis.llen("x").should == 2
      end
      
    end
    
    describe "#lrange" do

      before(:each) do
        @redis.rpush("x", "one").should == true
        @redis.rpush("x", "two").should == true
        @redis.rpush("x", "three").should == true
        @redis.rpush("x", "four").should == true
        @redis.rpush("x", "five").should == true
      end
      
      it "should support subsets" do
        @redis.lrange("x",1,2).should == ["two","three"]
      end

      it "should support full" do
        @redis.lrange("x",0,-1).should == ["one","two","three","four","five"]
      end

      it "should invalid ranges" do
        @redis.lrange("x",2,1).should == []
      end

      it "should out of bounds" do
        @redis.lrange("x",-1,1).should == ["one","two"]
      end

      it "should support nil" do
        @redis.lrange(nil,0,1).should == []
        @redis.lrange("",0,1).should == []
      end

      it "should support unknown" do
        @redis.lrange("blah",0,1).should == []
      end

    end
    
    describe "#multi" do
      
      it "should perform multiple tasks" do
        @redis.multi do
          @redis.rpush("x","one")
          @redis.rpush("x","two")
        end
        @redis.llen("x").should == 2
      end
      
    end
    

  end
end
