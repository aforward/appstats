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

    def self.run
      count = 0
      all = ResultJob.where("frequency <> 'once' or last_run_at IS NULL").all
      if all.size == 0
        Appstats.log(:info, "No result jobs to run.")
        return count
      end
      Appstats.log(:info, "About to analyze #{all.size} result job(s).")
      all.each do |job|
        if job.should_run
          Appstats.log(:info, "  - Job #{job.name} run [ID #{job.id}, FREQUENCY #{job.frequency}, QUERY #{job.query}]")
          query = Appstats::Query.new(:name => job.name, :result_type => "result_job", :query => job.query)
          query.run
          job.last_run_at = Time.now
          job.save
          count += 1
        else
          Appstats.log(:info, "  - Job #{job.name} NOT run [ID #{job.id}, FREQUENCY #{job.frequency}, QUERY #{job.query}]")
        end
      end
      Appstats.log(:info, "Ran #{count} query(ies).")
      count
    end

    private

      def state
        [name, frequency, status, query, last_run_at]
      end

    
  end
end