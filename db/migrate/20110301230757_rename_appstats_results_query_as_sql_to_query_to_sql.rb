class RenameAppstatsResultsQueryAsSqlToQueryToSql < ActiveRecord::Migration
  def self.up
    rename_column :appstats_results, :query_as_sql, :query_to_sql
  end

  def self.down
    rename_column :appstats_results, :query_to_sql, :query_as_sql
  end
end
