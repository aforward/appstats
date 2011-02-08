
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

    def to_s
      s = ""
      return s if @year.nil?
      s += "#{@year}"

      return s if @month.nil?
      s += "-#{@month.to_s.rjust(2,'0')}"

      return s if @day.nil?
      s += "-#{@day.to_s.rjust(2,'0')}"

      return s if @hour.nil?
      s += " #{@hour.to_s.rjust(2,'0')}"

      return s if @min.nil?
      s += ":#{@min.to_s.rjust(2,'0')}"

      return s if @sec.nil?
      s += ":#{@sec.to_s.rjust(2,'0')}"
      
      s
    end
    
    def self.parse(raw_input)
      date = EntryDate.new
      return date if raw_input.nil? || raw_input == ''
      input = raw_input.strip

      if input.match(/^\d*$/) # year
        date.year = input.to_i
        return date
      end
      
      t = Time.now
      t_parts = nil
      
      if input.match(/^YTD|ytd$/)
        t_parts = [:year]
      elsif input.match(/^today$/)
        t_parts = [:year,:month,:day]
      elsif input.match(/^yesterday$/)
        t -= 1.day
        t_parts = [:year,:month,:day]
      elsif input.match(/^this year$/)
        t_parts = [:year]
      elsif input.match(/^this month$/)
        t_parts = [:year,:month]
      elsif input.match(/^this week$/)
        t = t.beginning_of_week
        t_parts = [:year,:month,:day]
      elsif input.match(/^this day$/)
        t_parts = [:year,:month,:day]
      elsif input.match(/^(.*),[^\d]*(\d*)$/) # month, year
        t = Time.parse(input)
        t_parts = [:year,:month]
      elsif input.match(/^(\d*)-(\d*)-(\d*)$/) # YYYY-mm-dd
        t = Time.parse(input)
        t_parts = [:year,:month,:day]
      end

      m = input.match(/^last\s*(\d*)\s*years?$/)
      if m
        amount = m[1] == "" ? 1 : m[1].to_i
        t -= amount.year
        t_parts = [:year]
      end
      
      m = input.match(/^last\s*(\d*)\s*months?$/)
      if m
        amount = m[1] == "" ? 1 : m[1].to_i
        t -= amount.month
        t_parts = [:year,:month]
      end

      m = input.match(/^last\s*(\d*)\s*weeks?$/)
      if m
        amount = m[1] == "" ? 1 : m[1].to_i
        t = (t - amount.week).beginning_of_week
        t_parts = [:year,:month,:day]
      end

      m = input.match(/^last\s*(\d*)\s*days?$/)
      if m
        amount = m[1] == "" ? 1 : m[1].to_i
        t -= amount.day
        t_parts = [:year,:month,:day]
      end

      unless t_parts.nil?
        t_parts.each do |label|
          date.send("#{label}=",t.send(label))
        end
        return date
      end
      

      begin
        t = Time.parse(input)
        return EntryDate.new(:year => t.year, :month => t.month, :day => t.day, :hour => t.hour, :min => t.min, :sec => t.sec)
      rescue
        return EntryDate.new
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