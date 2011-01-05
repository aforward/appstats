class CreateAppstatsEntries < ActiveRecord::Migration
  def self.up
    create_table :appstats_entries do |t|
      t.string :entry_type
      t.string :name, :null => false
      t.string :description
      t.timestamps
    end
  end

  def self.down
    drop_table :appstats_entries
  end
end
