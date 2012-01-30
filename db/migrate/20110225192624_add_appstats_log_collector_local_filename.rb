class AddAppstatsLogCollectorLocalFilename < ActiveRecord::Migration
  def self.up
    add_column :appstats_log_collectors, :local_filename, :string
  end

  def self.down
    remove_column :appstats_log_collectors, :local_filename
  end
end
