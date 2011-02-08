
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
      
      m = input.match(/^today|yesterday|YTD|ytd$/)
      unless m.nil?
        range.from = EntryDate.parse(input)
        range.format = "fixed_point"
      end
      
      m = input.match(/^between\s*(.*)\s*and\s*(.*)$/)
      unless m.nil?
        range.from = EntryDate.parse(m[1])
        range.to = EntryDate.parse(m[2])
        return range
      end
      
      m = input.match(/^(in|on)\s*(.*)$/)
      unless m.nil?
        range.from = EntryDate.parse(m[2])
        range.format = "fixed_point"
        return range
      end

      m = input.match(/^before\s*(.*)$/)
      unless m.nil?
        range.to = EntryDate.parse(m[1])
        range.format = "exclusive"
        return range
      end

      m = input.match(/^after\s*(.*)$/)
      unless m.nil?
        range.from = EntryDate.parse(m[1])
        range.format = "exclusive"
        return range
      end

      m = input.match(/^since\s*(.*)$/)
      unless m.nil?
        range.from = EntryDate.parse(m[1])
        range.format = "inclusive"
        return range
      end


      m = input.match(/^this\s*(year|month|week|day)$/)
      unless m.nil?
        range.from = EntryDate.parse(input)
        range.format = m[1] == "week" ? "inclusive" : "fixed_point"
        return range
      end

      m = input.match(/^(last|previous)\s*(year|month|week|day)$/)
      unless m.nil?
        range.from = EntryDate.parse(input)
        if m[2] == "week"
          range.to = range.from.end_of_week
          range.format = "inclusive"
        else
          range.format = "fixed_point"  
        end
        return range
      end

      m = input.match(/^last\s*(.+)\s*(year|years|month|months|week|weeks|day|days)$/)
      unless m.nil?
        range.from = EntryDate.parse(input)
        range.format = "inclusive"
        return range
      end

      m = input.match(/^previous\s*(.+)\s*(year|month|week|day)s?$/)
      unless m.nil?
        range.from = EntryDate.parse(input)
        to = EntryDate.parse("last #{m[2]}")
        to = to.end_of_week if m[2] == "week"
        range.to = to
        range.format = "inclusive"
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