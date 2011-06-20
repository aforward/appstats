class CreateAppstatsActionContexts < ActiveRecord::Migration
  def self.up
    create_table :appstats_action_context_keys do |t|
      t.string :action_name
      t.string :context_key
      t.string :status
      t.timestamps
    end
  end

  def self.down
    drop_table :appstats_action_context_keys
  end
end
