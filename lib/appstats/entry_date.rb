
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
    
    def end_of_week
      week = self.dup
      t = to_time.end_of_week
      week.year = t.year
      week.month = t.month
      week.day = t.day
      week  
    end

    def end_of_quarter
      t = to_time.end_of_quarter
      EntryDate.new(:year => t.year, :month => t.month)
    end

    def to_time(mode = :start)
      return Time.now if @year.nil?
      t = Time.parse("#{@year}-#{@month||'01'}-#{@day||'01'} #{@hour||'00'}:#{@min||'00'}:#{@sec||'00'}")
      
      if mode == :end
        t = t.end_of_year if @month.nil?
        t = t.end_of_month if @day.nil?
        t = t.end_of_day if @hour.nil?
      end
      t
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
      elsif input.match(/^this quarter$/)
        t = t.beginning_of_quarter
        t_parts = [:year,:month]
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

      m = input.match(/^(last|previous)\s*(\d*)\s*years?$/)
      if m
        t -= last_date_offset(m).year
        t_parts = [:year]
      end

      m = input.match(/^(last|previous)\s*(\d*)\s*quarters?$/)
      if m
        t = t.beginning_of_quarter
        last_date_offset(m).times { t = (t - 1.day).beginning_of_quarter }
        t_parts = [:year,:month]
      end
      
      m = input.match(/^(last|previous)\s*(\d*)\s*months?$/)
      if m
        t -= last_date_offset(m).month
        t_parts = [:year,:month]
      end

      m = input.match(/^(last|previous)\s*(\d*)\s*weeks?$/)
      if m
        t = (t - last_date_offset(m).week).beginning_of_week
        t_parts = [:year,:month,:day]
      end

      m = input.match(/^(last|previous)\s*(\d*)\s*days?$/)
      if m
        t -= last_date_offset(m).day
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
      
      # (last|previous) (\d*)
      def self.last_date_offset(match)
        offset = match[1] == "last" ? -1 : 0
        amount = match[2] == "" ? 1 : match[2].to_i + offset
        amount
      end
  
  end
end