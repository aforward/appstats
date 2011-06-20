class AddAppstatsResultsContexts < ActiveRecord::Migration
  def self.up
    add_column :appstats_results, :contexts, :text
  end

  def self.down
    remove_column :appstats_results, :contexts
  end
end
