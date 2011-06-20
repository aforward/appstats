class AddAdditionalContextsIndexes < ActiveRecord::Migration
  def self.up
    add_index :appstats_contexts, :context_key
    add_index :appstats_contexts, :context_value
  end

  def self.down
    remove_index :appstats_contexts, :context_key
    remove_index :appstats_contexts, :context_value
  end
end
