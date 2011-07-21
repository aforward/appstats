module Appstats
  class Result < ActiveRecord::Base
    set_table_name "appstats_results"
    establish_connection "appstats_#{Rails.env}" if configurations.keys.include?("appstats_#{Rails.env}")

    attr_accessible :name, :result_type, 
      :query, :query_to_sql, :count, :query_type, :query_duration_in_seconds, :group_query_duration_in_seconds,
      :action, :host, :from_date, :to_date, :contexts, :group_by,  
      :db_username, :db_name, :db_host, :is_latest

    has_many :sub_results, :class_name => "Appstats::SubResult", :table_name => 'appstats_subresults', :foreign_key => 'appstats_result_id', :order => 'count DESC'
    after_save :update_is_latest

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
    
    def host_to_s
      return host if (db_host.blank? || host == db_host)
      return db_host if host.blank?
      "#{host} (host), #{db_host} (db_host)"
    end
    
    def query_duration_to_s
      FriendlyTimer.calculate_duration_to_s(query_duration_in_seconds)
    end
    
    def group_query_duration_to_s
      FriendlyTimer.calculate_duration_to_s(group_query_duration_in_seconds)
    end
    
    def count_to_s(data = {})
      Appstats::Result.calculate_count_to_s(count,data)
    end

    def ==(o)
       o.class == self.class && o.send(:state) == state
    end
    alias_method :eql?, :==

    def self.fix_all_is_latest
      connection.update('update appstats_results set is_latest = false')
      all = connection.select_all("select concat(id,' ',max(updated_at)) as id_and_date from appstats_results group by query")
      return if all.empty?
      ids = all.each.collect { |e| e["id_and_date"].split[0] }.compact
      connection.update("update appstats_results set is_latest = '1' where id in (#{ids.join(',')})")
    end
    
    def self.calculate_count_to_s(raw_count,data = {})
      return "--" if raw_count.nil?
      if data[:format] == :short_hand
        lookups = { 1000.0 => 'thousand', 1000000.0 => 'million', 1000000000.0 => 'billion', 1000000000000.0 => 'trillion' }
        lookups.keys.sort.reverse.each do |v|
          next if v > raw_count
          short_hand = (raw_count / v * 10).round / 10.0
          short_hand = short_hand.round if short_hand.round == short_hand
          return "#{add_commas(short_hand)} #{lookups[v]}"
        end
      end
      add_commas(raw_count)
    end

    private

      def update_is_latest
        sql = ["update appstats_results set is_latest = false where query = ?",query]
        connection.update(ActiveRecord::Base.send(:sanitize_sql_array, sql))
        
        sql = ["select id from appstats_results where query = ? order by updated_at DESC",query]
        first = connection.select_one(ActiveRecord::Base.send(:sanitize_sql_array, sql))
        return if first.nil?
        
        sql = ["update appstats_results set is_latest = '1' where id = ?",first["id"]]
        connection.update(ActiveRecord::Base.send(:sanitize_sql_array, sql))
      end

      def self.add_commas(num)
        num.to_s.gsub(/(\d)(?=\d{3}+(\.\d*)?$)/, '\1,')
      end

      def state
        [name, result_type, query, query_to_sql, count, action, host, from_date, to_date,contexts,group_by,query_type,db_username,db_name,db_host]
      end

    
  end
end