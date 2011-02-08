
module Appstats
  class DateRange

    attr_accessor :from, :to, :format
    
    def initialize(data = {})
      @from = data[:from]
      @to = data[:to]
      @format = data[:format] || "inclusive"
    end

    def self.parse(raw_input)
      range = DateRange.new
      return range if raw_input.nil? || raw_input == ''
      input = raw_input.strip
      
      m = input.match(/today|yesterday|YTD|ytd/)
      unless m.nil?
        range.from = EntryDate.parse(input)
        range.format = "fixed_point"
      end
      
      m = input.match(/between (.*) and (.*)/)
      unless m.nil?
        range.from = EntryDate.parse(m[1])
        range.to = EntryDate.parse(m[2])
        return range
      end
      
      m = input.match(/[in|on] (.*)/)
      unless m.nil?
        range.from = EntryDate.parse(m[1])
        range.format = "fixed_point"
        return range
      end

      m = input.match(/before (.*)/)
      unless m.nil?
        range.to = EntryDate.parse(m[1])
        range.format = "exclusive"
        return range
      end

      m = input.match(/after (.*)/)
      unless m.nil?
        range.from = EntryDate.parse(m[1])
        range.format = "exclusive"
        return range
      end
      
      range
    end

    def ==(o)
       o.class == self.class && o.send(:state) == state
    end
    alias_method :eql?, :==

    private

      def state
        [@from, @to, @format]
      end
  
  end
end