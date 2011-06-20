class CreateAppstatsHosts < ActiveRecord::Migration
  def self.up
    create_table :appstats_hosts do |t|
      t.string :name
      t.string :status
      t.timestamps
    end
  end

  def self.down
    drop_table :appstats_hosts
  end
end