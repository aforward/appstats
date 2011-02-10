
module Appstats
  class DateRange

    attr_accessor :from, :to, :format
    
    def initialize(data = {})
      @from = data[:from]
      @to = data[:to]
      @format = data[:format] || :inclusive
    end
    
    def from_to_s
      return nil if @from.nil?
      mode = @format == :inclusive ? :start : :end
      @from.to_time(mode).strftime('%Y-%m-%d %H:%M:%S')
    end

    def to_to_s
      return nil if @to.nil?
      mode = @format == :exclusive ? :start : :end
      @to.to_time(mode).strftime('%Y-%m-%d %H:%M:%S')
    end
    
    def to_sql
      return "1=1" if @from.nil? && @to.nil?
      
      if !@from.nil? && @to.nil?
        return case @format
          when :inclusive then 
            "occurred_at >= '#{from_to_s}'"
          when :exclusive then 
            "occurred_at > '#{from_to_s}'"
          when :fixed_point then 
            answer = "("
            [:year,:month,:day,:hour,:min,:sec].each do |t|
              next if from.send(t).nil?
              answer += " and " unless answer.size == 1
              answer += "#{t}=#{from.send(t)}"
            end
            answer += ")"
            answer 
        end
      elsif @from.nil? && !@to.nil?
        return case @format
          when :inclusive then "occurred_at <= '#{to_to_s}'"
          when :exclusive then "occurred_at < '#{to_to_s}'"
          else "1=1"
        end
      else
        return case @format
          when :inclusive then "(occurred_at >= '#{from_to_s}' and occurred_at <= '#{to_to_s}')"
          when :exclusive then "(occurred_at > '#{from_to_s}' and occurred_at < '#{to_to_s}')"
          else "1=1"
        end
      end
      
      
    end 

    def self.parse(raw_input)
      range = DateRange.new
      return range if raw_input.nil? || raw_input == ''
      input = raw_input.strip
      
      m = input.match(/^today|yesterday|YTD|ytd$/)
      unless m.nil?
        range.from = EntryDate.parse(input)
        range.format = :fixed_point
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
        range.format = :fixed_point
        return range
      end

      m = input.match(/^before\s*(.*)$/)
      unless m.nil?
        range.to = EntryDate.parse(m[1])
        range.format = :exclusive
        return range
      end

      m = input.match(/^after\s*(.*)$/)
      unless m.nil?
        range.from = EntryDate.parse(m[1])
        range.format = :exclusive
        return range
      end

      m = input.match(/^since\s*(.*)$/)
      unless m.nil?
        range.from = EntryDate.parse(m[1])
        range.format = :inclusive
        return range
      end


      m = input.match(/^this\s*(year|month|week|day)$/)
      unless m.nil?
        range.from = EntryDate.parse(input)
        range.format = m[1] == "week" ? :inclusive : :fixed_point
        return range
      end

      m = input.match(/^(last|previous)\s*(year|month|week|day)$/)
      unless m.nil?
        range.from = EntryDate.parse(input)
        if m[2] == "week"
          range.to = range.from.end_of_week
          range.format = :inclusive
        else
          range.format = :fixed_point  
        end
        return range
      end

      m = input.match(/^last\s*(.+)\s*(year|years|month|months|week|weeks|day|days)$/)
      unless m.nil?
        range.from = EntryDate.parse(input)
        range.format = :inclusive
        return range
      end

      m = input.match(/^previous\s*(.+)\s*(year|month|week|day)s?$/)
      unless m.nil?
        range.from = EntryDate.parse(input)
        to = EntryDate.parse("last #{m[2]}")
        to = to.end_of_week if m[2] == "week"
        range.to = to
        range.format = :inclusive
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