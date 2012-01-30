class CreateAppstatsContextKeys < ActiveRecord::Migration
  def self.up
    create_table :appstats_context_keys do |t|
      t.string :name
      t.string :status
      t.timestamps
    end
  end

  def self.down
    drop_table :appstats_context_keys
  end
end
