class AddAppstatsContextIndexes < ActiveRecord::Migration
  def self.up
    add_index :appstats_contexts, [:appstats_entry_id, :context_key,:context_value], :name => "index_contexts_entry_key_value"    
    add_index :appstats_contexts, [:appstats_entry_id, :context_key,:context_int], :name => "index_contexts_entry_key_int"    
    add_index :appstats_contexts, [:appstats_entry_id, :context_key,:context_float], :name => "index_contexts_entry_key_float"    
  end

  def self.down
    remove_index :appstats_contexts, :name => "index_contexts_entry_key_value"
    remove_index :appstats_contexts, :name => "index_contexts_entry_key_int"
    remove_index :appstats_contexts, :name => "index_contexts_entry_key_float"
  end
end
