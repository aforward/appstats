class AddAppstatsEntriesWeekAndQuarter < ActiveRecord::Migration
  def self.up
    add_column :appstats_entries, :week, :integer
    add_column :appstats_entries, :quarter, :integer
    add_index :appstats_entries, [:year,:week], :name => "index_entries_by_week"
    add_index :appstats_entries, [:year,:quarter], :name => "index_entries_by_quarter"
  end

  def self.down
    remove_column :appstats_entries, :week
    remove_column :appstats_entries, :quarter
    remove_index :appstats_entries, :name => "index_entries_by_week"
    remove_index :appstats_entries, :name => "index_entries_by_quarter"
  end
end
