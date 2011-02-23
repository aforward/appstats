
module Appstats
  class DateRange

    attr_accessor :from, :to, :format
    
    def initialize(data = {})
      @from = data[:from]
      @to = data[:to]
      @format = data[:format] || :inclusive
    end
    
    def from_date
      return nil if @from.nil?
      mode = @format == :exclusive ? :end : :beginning
      @from.to_time(mode)
    end
    
    def to_date
      if @format == :fixed_point && !@from.nil?
        return @from.to_time(:end)
      end
      return nil if @to.nil?
      mode = @format == :exclusive ? :beginning : :end
      @to.to_time(mode)
    end
    
    def from_date_to_s
      return nil if from_date.nil?
      from_date.strftime('%Y-%m-%d %H:%M:%S')
    end

    def to_date_to_s
      return nil if to_date.nil?
      to_date.strftime('%Y-%m-%d %H:%M:%S')
    end
    
    def to_sql
      return "1=1" if @from.nil? && @to.nil?
      
      if !@from.nil? && @to.nil?
        return case @format
          when :inclusive then 
            "occurred_at >= '#{from_date_to_s}'"
          when :exclusive then 
            "occurred_at > '#{from_date_to_s}'"
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
          when :inclusive then "occurred_at <= '#{to_date_to_s}'"
          when :exclusive then "occurred_at < '#{to_date_to_s}'"
          else "1=1"
        end
      else
        return case @format
          when :inclusive then "(occurred_at >= '#{from_date_to_s}' and occurred_at <= '#{to_date_to_s}')"
          when :exclusive then "(occurred_at > '#{from_date_to_s}' and occurred_at < '#{to_date_to_s}')"
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


      m = input.match(/^this\s*(year|quarter|month|week|day)$/)
      unless m.nil?
        range.from = EntryDate.parse(input)
        range.format = :fixed_point
        return range
      end

      m = input.match(/^(last|previous)\s*(year|quarter|month|week|day)$/)
      unless m.nil?
        range.from = EntryDate.parse(input)
        range.format = :fixed_point
        return range
      end

      m = input.match(/^last\s*(.+)\s*(year|years|quarter|quarters|month|months|week|weeks|day|days)$/)
      unless m.nil?
        range.from = EntryDate.parse(input)
        range.format = :inclusive
        return range
      end

      m = input.match(/^previous\s*(.+)\s*(year|quarter|month|week|day)s?$/)
      unless m.nil?
        range.from = EntryDate.parse(input)
        to = EntryDate.parse("last #{m[2]}")
        if m[2] == "week"
          to = to.end_of_week
        elsif m[2] == "quarter"
          to = to.end_of_quarter  
        end
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