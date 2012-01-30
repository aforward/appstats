class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :appstats_log_collectors, :host
    add_index :appstats_entries, :action
    add_index :appstats_entries, :year, :name => "index_entries_by_year"
    add_index :appstats_entries, [:year,:month], :name => "index_entries_by_month"
    add_index :appstats_entries, [:year,:month,:day], :name => "index_entries_by_day"
    add_index :appstats_entries, [:year,:month,:day,:hour], :name => "index_entries_by_hour"
    add_index :appstats_entries, [:year,:month,:day,:hour,:minute], :name => "index_entries_by_minute"
    add_index :appstats_contexts, [:context_key,:context_value]
    add_index :appstats_contexts, [:context_key,:context_int]
    add_index :appstats_contexts, [:context_key,:context_float]
  end

  def self.down
    remove_index :appstats_log_collectors, :host
    remove_index :appstats_entries, :action
    remove_index :appstats_entries, :name => "index_entries_by_year"
    remove_index :appstats_entries, :name => "index_entries_by_month"
    remove_index :appstats_entries, :name => "index_entries_by_day"
    remove_index :appstats_entries, :name => "index_entries_by_hour"
    remove_index :appstats_entries, :name => "index_entries_by_minute"
    remove_index :appstats_contexts, [:context_key,:context_value]
    remove_index :appstats_contexts, [:context_key,:context_int]
    remove_index :appstats_contexts, [:context_key,:context_float]
  end
end
