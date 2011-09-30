require "redis"
require "benchmark"

module Appstats
  class Benchmarker
  
    attr_accessor :redis
  
    def initialize(data = {})
      @redis = data[:redis] || Redis.new
    end
  
    def measure(title,legend)
      time = Benchmark.measure do
        yield
      end
      record(title,legend,time.real)
      time
    end
  
    def record(title,legend,point)
      redis.multi do
        redis.sadd "benchmarks", title
        redis.sadd "benchmarks:#{title}", legend
        redis.rpush "benchmarks:#{title}:#{legend}", point
      end
    end
  end
end