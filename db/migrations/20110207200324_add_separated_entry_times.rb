class AddSeparatedEntryTimes < ActiveRecord::Migration
  def self.up
    add_column :appstats_entries, :year, :int
    add_column :appstats_entries, :month, :int
    add_column :appstats_entries, :day, :int
    add_column :appstats_entries, :hour, :int
    add_column :appstats_entries, :minute, :int
    add_column :appstats_entries, :second, :int
  end

  def self.down
    remove_column :appstats_entries, :year
    remove_column :appstats_entries, :month
    remove_column :appstats_entries, :day
    remove_column :appstats_entries, :hour
    remove_column :appstats_entries, :minute
    remove_column :appstats_entries, :second
  end
end
