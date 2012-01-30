class ReworkAppstatsEntries < ActiveRecord::Migration
  def self.up
    drop_table :appstats_entries
    create_table :appstats_entries do |t|
      t.string :action
      t.datetime :occurred_at
      t.text :raw_entry
      t.timestamps
    end
  end

  def self.down
    drop_table :appstats_entries
    create_table :appstats_entries do |t|
      t.string :entry_type
      t.string :name, :null => false
      t.string :description
      t.timestamps
    end
  end
end
