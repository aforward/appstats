class AddTestObjectColumns < ActiveRecord::Migration
  def self.up
    add_column :appstats_test_objects, :last_name, :string
    [:binary,:boolean,:date,:datetime,:decimal,:float,:integer,:string,:text,:time,:timestamp].each do |type|
      add_column :appstats_test_objects, "blah_#{type}", type  
    end
  end

  def self.down
    remove_column :appstats_test_objects, :last_name
    [:binary,:boolean,:date,:datetime,:decimal,:float,:integer,:string,:text,:time,:timestamp].each do |type|
      remove_column :appstats_test_objects, "blah_#{type}"
    end
  end

end
