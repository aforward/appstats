require "redis"

module Appstats
  class Benchmarker
  
    attr_accessor :redis
  
    def initialize(data = {})
      @redis = data[:redis] || Redis.new
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