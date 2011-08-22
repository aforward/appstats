class AddAppstatsResultsLatestFlag < ActiveRecord::Migration
  def self.up
    add_column :appstats_results, :is_latest, :boolean
    add_index :appstats_results, :is_latest
    
    ActiveRecord::Base.connection.update('update appstats_results set is_latest = false')
    all = ActiveRecord::Base.connection.select_all("select concat(id,' ',max(updated_at)) as id_and_date from appstats_results group by query")
    return if all.empty?
    ids = all.each.collect { |e| e["id_and_date"].split[0] }.compact
    ActiveRecord::Base.connection.update("update appstats_results set is_latest = '1' where id in (#{ids.join(',')})")
  end

  def self.down
    remove_index :appstats_results, :is_latest
    remove_column :appstats_results, :is_latest
  end
end
