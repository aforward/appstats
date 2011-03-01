class AddAppstatsResultsGroups < ActiveRecord::Migration
  def self.up
    add_column :appstats_results, :group_by, :string
  end

  def self.down
    remove_column :appstats_results, :group_by
  end
end
