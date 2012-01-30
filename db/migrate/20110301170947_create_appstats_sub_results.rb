class CreateAppstatsSubResults < ActiveRecord::Migration
  def self.up
    create_table :appstats_sub_results do |t|
      t.integer :appstats_result_id
      t.string :context_filter
      t.integer :count
      t.float :ratio_of_total
      t.timestamps
    end
    
    add_index :appstats_sub_results, :context_filter
  end

  def self.down
    remove_index :appstats_sub_results, :context_filter
    
    drop_table :appstats_sub_results
  end
end
