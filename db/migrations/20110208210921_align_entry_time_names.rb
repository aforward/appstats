class AlignEntryTimeNames < ActiveRecord::Migration
  def self.up
    remove_index :appstats_entries, :name => "index_entries_by_minute"
    rename_column :appstats_entries, :minute, :min
    rename_column :appstats_entries, :second, :sec
    add_index :appstats_entries, [:year,:month,:day,:hour,:min], :name => "index_entries_by_minute"
  end

  def self.down
    remove_index :appstats_entries, :name => "index_entries_by_minute"
    rename_column :appstats_entries, :min, :minute
    rename_column :appstats_entries, :sec, :second
    add_index :appstats_entries, [:year,:month,:day,:hour,:minute], :name => "index_entries_by_minute"
  end
end
