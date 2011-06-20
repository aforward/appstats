class CreateAppstatsTestObject < ActiveRecord::Migration
  def self.up
    create_table :appstats_test_objects do |t|
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :appstats_test_objects
  end
end
