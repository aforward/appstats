class AddAppstatsResultsQueryDurationInSeconds < ActiveRecord::Migration
  def self.up
    add_column :appstats_results, :query_duration_in_seconds, :float
    add_column :appstats_results, :group_query_duration_in_seconds, :float
  end

  def self.down
    remove_column :appstats_results, :query_duration_in_seconds
    remove_column :appstats_results, :group_query_duration_in_seconds
  end
end
