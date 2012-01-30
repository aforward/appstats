class AddAppstatsResultsDbConnection < ActiveRecord::Migration
  def self.up
    add_column :appstats_results, :db_username, :string
    add_column :appstats_results, :db_name, :string
    add_column :appstats_results, :db_host, :string
  end

  def self.down
    remove_column :appstats_results, :db_username
    remove_column :appstats_results, :db_name
    remove_column :appstats_results, :db_host
  end
end
