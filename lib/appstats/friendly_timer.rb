
module Appstats
  class FriendlyTimer

    attr_accessor :duration, :start_time, :stop_time
    
    def initialize(data = {})
      @duration = data[:duration]
      start
    end
    
    def start
      @start_time = Time.now
      @start_time
    end
    
    def stop
      @stop_time = Time.now
      update_duration_as_required
      @stop_time
    end
  
    def duration_to_s
      FriendlyTimer.calculate_duration_to_s(duration)
    end
    
    def self.calculate_duration_to_s(duration_in_seconds)
      return "N/A" if duration_in_seconds.nil?
      
      #TODO use sortable hash if ruby 1.9.2
      times = [ 60*60*24*365.0, 60*60*24.0, 60*60.0, 60.0, 1.0, 0.001]
      names = [ 'year','day','hour','minute','second', 'millisecond']
      
      times.each_with_index do |factor,index|
        adjusted_time = duration_in_seconds / factor
        next if (adjusted_time < 1 && factor != 0.001)
        adjusted_time = (adjusted_time * 100).round / 100.0
        adjusted_time = adjusted_time.round if adjusted_time == adjusted_time.round
        name = adjusted_time == 1 ? names[index] : names[index].pluralize
        return "#{adjusted_time} #{name}"
      end      
    end
  
    private
    
      def update_duration_as_required
        return if @start_time.nil? || @stop_time.nil?
        @duration = @stop_time - @start_time
      end
  
  end
end