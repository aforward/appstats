
module Appstats
  class AppstatsQuery

    attr_accessor :query
  
    @@default_query = "select 0 as num"
  
    @@action_to_available_contexts = 
    {
      "appstats_queries" => [ "action", "contexts", "group_by" ],
      "booms" => []
    }
  
    def query_to_sql
      return @@default_query if query.nil?
      query.query_to_sql
    end
  
    def group_query_to_sql
      return nil if query.nil?
      query.group_query_to_sql
    end
  
    def process_query
      return if query.nil?
      query.query_to_sql = @@default_query
      query.group_query_to_sql = nil
      return if query.action.blank?
  
      action = query.action.pluralize.downcase
      case action
        when "appstats_queries"
          count_filter = "COUNT(*)"
          query.query_to_sql = "select #{count_filter} as num from appstats_results#{build_where_clause}"
        when "booms"
          query.query_to_sql = "invalid sql"
      end
      query.group_query_to_sql = query.query_to_sql.sub("#{count_filter} as num","#{context_key_filter_name(action)} as context_key_filter, #{context_value_filter_name(action)} as context_value_filter, COUNT(*) as num") + " group by context_value_filter" unless query.group_by.empty?
    end
  
    def run
      query.run
    end
  
    def db_connection
      Appstats.connection
    end
  
    def self.available_action?(action)
      return false if action.blank?
      return @@action_to_available_contexts.keys.include?(action.downcase.pluralize)
    end
  
    private
  
      def build_where_clause
        where_clause = ""
        action = query.action.pluralize.downcase
        available_contexts = @@action_to_available_contexts[action]
        status = :context
        query.parsed_contexts.each do |lookup|
          next if status == :context && lookup.kind_of?(String)
          next if status == :join && !lookup.kind_of?(String)
          next if status == :context && (lookup[:context_value].nil? || !available_contexts.include?(lookup[:context_key]))
        
          where_clause = " where" if where_clause.blank?
          if lookup.kind_of?(String)
            where_clause += " #{lookup}" 
            status = :context
          elsif !lookup[:context_value].nil? && available_contexts.include?(lookup[:context_key])
            where_clause += " #{database_column(action,lookup[:context_key])} #{lookup[:comparator]} '#{Appstats::Query.sqlclean(lookup[:context_value])}'"
            status = :join
          end
        end
        where_clause
      end
    
      def context_key_filter_name(action)
        "'" + query.group_by.join(",") + "'"      
      end
    
      def context_value_filter_name(action)
        database_names = query.group_by.collect do |name|
          database_column(action,name)
        end
        "concat(ifnull("+ database_names.join(",'--'),',',ifnull(") +",'--'))"
      end
  
      def database_column(action,name)
        name
      end

  end
end