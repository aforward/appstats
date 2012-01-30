class CreateAppstatsContexts < ActiveRecord::Migration
  def self.up
    create_table :appstats_contexts do |t|
      t.string :context_key
      t.string :context_value
      t.integer :context_int
      t.float :context_float
      t.integer :appstats_entry_id
      t.timestamps
    end
  end

  def self.down
    drop_table :appstats_contexts
  end
end
