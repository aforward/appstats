module Appstats
  class Result < ActiveRecord::Base
    set_table_name "appstats_results"

    attr_accessible :name, :result_type, :query, :query_as_sql, :count, :action, :host, :from_date, :to_date, :contexts

    def date_to_s
      return "" if from_date.nil? && to_date.nil?
      
      from_s = nil
      to_s = nil
      
      if !from_date.nil? && to_date.nil? && created_at.nil?
        from_s = from_date_to_s
        to_s = "present"
      elsif !from_date.nil? && to_date.nil? && !created_at.nil?
        from_s = from_date_to_s
        to_s = created_at.strftime('%Y-%m-%d')
      elsif from_date.nil? && !to_date.nil?
        from_s = "up"
        to_s = to_date_to_s
      else
        from_s = from_date_to_s
        to_s = to_date_to_s
      end
      
      return from_s if from_s == to_s
      "#{from_s} to #{to_s}"
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
        [name, result_type, query, query_as_sql, count, action, host, from_date, to_date,contexts]
      end

    
  end
end