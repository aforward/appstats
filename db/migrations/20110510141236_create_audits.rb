class CreateAudits < ActiveRecord::Migration
  def self.up
    create_table :appstats_audits do |t|
      t.string :table_name
      t.string :column_type
      t.string :obj_name
      t.string :obj_attr
      t.string :obj_type
      t.integer :obj_id
      t.string :action
      t.string :old_value
      t.string :new_value
      t.text :old_value_full
      t.text :new_value_full
      t.timestamps
    end
  end

  def self.down
    drop_table :appstats_audits
  end
end
