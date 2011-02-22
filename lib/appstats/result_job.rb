module Appstats
  class ResultJob < ActiveRecord::Base
    set_table_name "appstats_result_jobs"

    attr_accessible :name, :frequency, :status, :query, :last_run_at

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