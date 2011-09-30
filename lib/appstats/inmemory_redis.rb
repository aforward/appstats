module Appstats
  class InmemoryRedis

    def initialize(data = {})
      @sets = {}
      @lists = {}
    end

    def scard(key)
      return 0 if @sets[key].nil?
      @sets[key].size
    end
    
    def sadd(key,member)
      @sets[key] = [] if @sets[key].nil?
      return false if @sets[key].include?(member)
      @sets[key] << member
      true
    end
    
    def llen(key)
      return 0 if @lists[key].nil?
      @lists[key].size
    end
    
    def rpush(key,value)
      @lists[key] = [] if @lists[key].nil?
      @lists[key] << value
      true
    end
    
    def lrange(key,start,stop)
      return [] if @lists[key].nil?
      start = 0 if start < 0
      max_stop = llen(key) - 1
      stop = max_stop if (stop == -1 || stop > max_stop)
      return [] if start > stop
      @lists[key][start..stop]
    end
    
    def multi
      yield
    end

  end
end