class CreateAppstatsJobs < ActiveRecord::Migration
  def self.up
    create_table :appstats_result_jobs do |t|
      t.string :name
      t.string :frequency
      t.string :status
      t.text :query
      t.datetime :last_run_at
      t.timestamps
    end
  end

  def self.down
    drop_table :appstats_result_jobs
  end
end
