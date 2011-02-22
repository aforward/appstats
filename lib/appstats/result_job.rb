module Appstats
  class ResultJob < ActiveRecord::Base
    set_table_name "appstats_result_jobs"

    attr_accessible :name, :frequency, :status, :query, :last_run_at

    @@frequency_methods = 

    def should_run
      return true if frequency == "once" && last_run_at.nil?
      period = { "daily" => :beginning_of_day, "weekly" => :beginning_of_week, "monthly" => :beginning_of_month, "quarterly" => :beginning_of_quarter, "yearly" => :beginning_of_year }[frequency]
      return false if period.nil?
      return true if last_run_at.nil?
      last_run_at.send(period) <= (Time.now.send(period) - 1.day).send(period)
    end

    def ==(o)
      o.class == self.class && o.send(:state) == state
    end
    alias_method :eql?, :==

    private

      def state
        [name, frequency, status, query, last_run_at]
      end

    
  end
end