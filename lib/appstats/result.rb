module Appstats
  class Result < ActiveRecord::Base
    set_table_name "appstats_results"

    attr_accessible :name, :result_type, :query, :query_to_sql, :count, :action, :host, :from_date, :to_date, :contexts, :group_by, :query_type, 
      :db_username, :db_name, :db_host
    has_many :sub_results, :table_name => 'appstats_subresults', :foreign_key => 'appstats_result_id', :order => 'count DESC'

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
    
    def count_to_s(data = {})
      return "--" if count.nil?
      if data[:format] == :short_hand
        lookups = { 1000.0 => 'thousand', 1000000.0 => 'million', 1000000000.0 => 'billion', 1000000000000.0 => 'trillion' }
        lookups.keys.sort.reverse.each do |v|
          next if v > count
          short_hand = (count / v * 10).round / 10.0
          short_hand = short_hand.round if short_hand.round == short_hand
          return "#{add_commas(short_hand)} #{lookups[v]}"
        end
      end
      add_commas(count)
    end

    def ==(o)
       o.class == self.class && o.send(:state) == state
    end
    alias_method :eql?, :==

    private

      def add_commas(num)
        num.to_s.gsub(/(\d)(?=\d{3}+(\.\d*)?$)/, '\1,')
      end

      def state
        [name, result_type, query, query_to_sql, count, action, host, from_date, to_date,contexts,group_by,query_type,db_username,db_name,db_host]
      end

    
  end
end