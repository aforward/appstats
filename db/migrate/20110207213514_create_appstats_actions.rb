class CreateAppstatsActions < ActiveRecord::Migration
  def self.up
    create_table :appstats_actions do |t|
      t.string :name
      t.string :plural_name
      t.string :status
      t.timestamps
    end
  end

  def self.down
    drop_table :appstats_actions
  end
end
