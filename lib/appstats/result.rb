module Appstats
  class Result < ActiveRecord::Base
    set_table_name "appstats_results"

    attr_accessible :name, :result_type, :query, :query_as_sql, :count, :action, :host, :from_date, :to_date

    def date_to_s
      return "" if from_date.nil? && to_date.nil?
      return "#{from_date_to_s} to present" if !from_date.nil? && to_date.nil? && created_at.nil?
      return "#{from_date_to_s} to #{created_at.strftime('%Y-%m-%d')}" if !from_date.nil? && to_date.nil? && !created_at.nil?
      return "up to #{to_date_to_s}" if from_date.nil? && !to_date.nil?
      "#{from_date_to_s} to #{to_date_to_s}"
    end

    def from_date_to_s
      return "" if from_date.nil?
      from_date.strftime('%Y-%m-%d')
    end

    def to_date_to_s
      return "" if to_date.nil?
      to_date.strftime('%Y-%m-%d')
    end

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