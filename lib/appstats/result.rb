module Appstats
  class Result < ActiveRecord::Base
    set_table_name "appstats_results"

    attr_accessible :name, :result_type, :query, :query_as_sql, :count, :action, :host, :from_date, :to_date

    def ==(o)
       o.class == self.class && o.send(:state) == state
    end
    alias_method :eql?, :==

    private

      def state
        [name, result_type, query, query_as_sql, count, action, host, from_date, to_date]
      end

    
  end
end