class CreateLogCollectors < ActiveRecord::Migration
  def self.up
    create_table :appstats_log_collectors do |t|
      t.string :host
      t.string :filename
      t.string :status
      t.timestamps
    end
    add_column :appstats_entries, :appstats_log_collector_id, :integer
  end

  def self.down
    drop_table :appstats_log_collectors
    remove_column :appstats_entries, :appstats_log_collector_id
  end
end
