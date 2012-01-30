class AddAppstatsResultsQueryType < ActiveRecord::Migration
  def self.up
    add_column :appstats_results, :query_type, :string
    add_column :appstats_result_jobs, :query_type, :string
  end

  def self.down
    remove_column :appstats_results, :query_type
    remove_column :appstats_result_jobs, :query_type
  end
end
