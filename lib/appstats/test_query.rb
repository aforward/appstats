
module Appstats
  class TestQuery

    attr_accessor :query, :query_to_sql, :group_query_to_sql

    def process_query
      query.query_to_sql = "select count(*) as num from appstats_test_objects"
      query.group_query_to_sql = "select context_key_filter, context_value_filter, count(*) as num from (select 'name' as context_key_filter, name as context_value_filter from appstats_test_objects) results group by context_value_filter"
    end
    
  end
  
  module Core
    class AnotherTestQuery
      attr_accessor :query
      def process_query; end
    end
  end
  
end

class YetAnotherTestQuery
  attr_accessor :query
  def process_query; end
end