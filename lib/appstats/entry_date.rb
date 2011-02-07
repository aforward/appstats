
module Appstats
  class EntryDate

    attr_accessor :year, :month, :day, :hour, :min, :sec
    
    def initialize(data = {})
      @year = data[:year]
      @month = data[:month]
      @day = data[:day]
      @hour = data[:hour]
      @min = data[:min]
      @sec = data[:sec]
    end
    
    
    def self.parse(raw_input)
      return EntryDate.new if raw_input.nil? || raw_input == ''
      if raw_input.match(/^\d*$/) # year
        EntryDate.new(:year => raw_input.to_i)
      elsif raw_input.match(/^(.*),[^\d]*(\d*)$/) # month, year
        t = Time.parse(raw_input)
        EntryDate.new(:year => t.year, :month => t.month)
      elsif raw_input.match(/^(\d*)-(\d*)-(\d*)$/) # YYYY-mm-dd
        t = Time.parse(raw_input)
        EntryDate.new(:year => t.year, :month => t.month, :day => t.day)
      else
        begin
          t = Time.parse(raw_input)
          EntryDate.new(:year => t.year, :month => t.month, :day => t.day, :hour => t.hour, :min => t.min, :sec => t.sec)
        rescue
          EntryDate.new
        end
      end
    end

    def ==(o)
       o.class == self.class && o.send(:state) == state
    end
    alias_method :eql?, :==

    private

      def state
        [@year, @month, @day, @hour, @min, @sec]
      end
  
  end
end