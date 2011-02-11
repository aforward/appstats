class CreateAppstatsResults < ActiveRecord::Migration
  def self.up
    create_table :appstats_results do |t|
      t.string :name
      t.string :result_type
      t.text :query
      t.text :query_as_sql
      t.integer :count
      t.string :action
      t.string :host
      t.integer :page
      t.datetime :from_date
      t.datetime :to_date
      t.timestamps
    end
    
    add_index :appstats_results, :name
    add_index :appstats_results, :action
    add_index :appstats_results, :host
    add_index :appstats_results, :page
    
  end

  def self.down
    
    remove_index :appstats_results, :name
    remove_index :appstats_results, :action
    remove_index :appstats_results, :host
    remove_index :appstats_results, :page
    
    drop_table :appstats_results
  end
end
