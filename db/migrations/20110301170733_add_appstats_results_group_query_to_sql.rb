class AddAppstatsResultsGroupQueryToSql < ActiveRecord::Migration
  def self.up
    add_column :appstats_results, :group_query_to_sql, :text
  end

  def self.down
    remove_column :appstats_results, :group_query_to_sql, :text
  end
end
