module Appstats
  class SubResult < ActiveRecord::Base
    set_table_name "appstats_sub_results"

    attr_accessible :context_filter, :count, :ratio_of_total
    belongs_to :result, :foreign_key => "appstats_result_id"

    def total_count
      return 0 if result.nil?
      result.count
    end

    def count_to_s(data = {})
      Appstats::Result.calculate_count_to_s(count,data)
    end

    def total_count_to_s(data = {})
      Appstats::Result.calculate_count_to_s(total_count,data)
    end
    
    def context_filter_to_s
      return "-- N/A --" if context_filter.nil?
      return "-- No Value --" if context_filter.empty?
      context_filter
    end


    def ==(o)
       o.class == self.class && o.send(:state) == state
    end
    alias_method :eql?, :==

    private

      def state
        [context_filter, count, ratio_of_total]
      end

    
  end
end