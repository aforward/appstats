require 'spec_helper'

module Appstats
  
  class Audit
    acts_as_auditable
  end 
  
  describe Audit do

    before(:each) do
      Appstats::Audit.delete_all
      @audit = Appstats::Audit.new
    end
    
    describe "#initialize" do

      it "should set info to nil" do
        @audit.table_name.should == nil
        @audit.column_type.should == nil
        @audit.obj_name.should == nil
        @audit.obj_attr.should == nil
        @audit.obj_type.should == nil
        @audit.obj_id.should == nil
        @audit.action.should == nil
        @audit.old_value.should == nil
        @audit.new_value.should == nil
        @audit.old_value_full.should == nil
        @audit.new_value_full.should == nil
      end

      it "should set on constructor" do
        audit = Appstats::Audit.new(:table_name => 'a', :column_type => 'aa', :obj_name => 'c', :obj_attr => 'd', :obj_type => 'dd', :obj_id => 99, :action => 'x', :old_value => 'e', :new_value => 'f', :old_value_full => 'g', :new_value_full => 'h')
        audit.table_name.should == 'a'
        audit.column_type.should == 'aa'
        audit.obj_name.should == 'c'
        audit.obj_attr.should == 'd'
        audit.obj_type.should == 'dd'
        audit.obj_id.should == 99
        audit.action.should == 'x'
        audit.old_value.should == 'e'
        audit.new_value.should == 'f'
        audit.old_value_full.should == 'g'
        audit.new_value_full.should == 'h'
      end
    
    end
    
    it "should ignore itself - even if requested" do
      Audit.create(:table_name => "ignore")
    end

    describe "save a new object" do
      
      it "should call audit_create" do
        t = TestObject.new(:name => 'a')
        Audit.should_receive(:audit_create).with(t,{}).and_return(5)
        t.save.should == true
      end
         
    end
    
    describe "update an existing object" do
      
      it "should call audit_update" do
        t = TestObject.create(:name => 'a')
        t.name = "x"
        Audit.should_receive(:audit_update).with(t,{}).and_return(2)
        t.save
      end
      
      it "should store the type" do
        t = TestObject.new
        
        t.blah_binary = "b"
        t.blah_boolean = true
        t.blah_date = Date.parse("2011-09-21")
        t.blah_datetime = DateTime.parse("2011-09-21 10:11:12")
        t.blah_decimal = 10.11
        t.blah_float = 0.33
        t.blah_integer = 10
        t.blah_string = "sss"
        t.blah_text = "moresss"
        t.blah_time = Time.parse("10:11:12")
        t.blah_timestamp = Time.parse("10:11:12").to_i

        t.save.should == true


        Audit.count.should == 15
        
        all = Audit.all
        all[0].column_type.should == nil
        all[0].obj_type.should == nil
        
        all[1].obj_attr.should == "blah_string"
        all[1].column_type.should == "varchar(255)"
        all[1].obj_type.should == "string"

        all[2].obj_attr.should == "created_at"
        all[2].column_type.should == "datetime"
        all[2].obj_type.should == "datetime"

        all[3].obj_attr.should == "blah_timestamp"
        all[3].column_type.should == "datetime"
        all[3].obj_type.should == "datetime"

        all[4].obj_attr.should == "updated_at"
        all[4].column_type.should == "datetime"
        all[4].obj_type.should == "datetime"

        all[5].obj_attr.should == "id"
        all[5].column_type.should == "int(11)"
        all[5].obj_type.should == "integer"

        all[6].obj_attr.should == "blah_decimal"
        all[6].column_type.should == "decimal(10,0)"
        all[6].obj_type.should == "integer"

        all[7].obj_attr.should == "blah_boolean"
        all[7].column_type.should == "tinyint(1)"
        all[7].obj_type.should == "boolean"

        all[8].obj_attr.should == "blah_binary"
        all[8].column_type.should == "blob"
        all[8].obj_type.should == "binary"

        all[9].obj_attr.should == "blah_time"
        all[9].column_type.should == "time"
        all[9].obj_type.should == "time"

        all[10].obj_attr.should == "blah_text"
        all[10].column_type.should == "text"
        all[10].obj_type.should == "text"

        all[11].obj_attr.should == "blah_integer"
        all[11].column_type.should == "int(11)"
        all[11].obj_type.should == "integer"
      end
      
    end

    describe "destroy an object" do
      
      it "should call audit_destroy" do
        t = TestObject.create(:name => 'a')
        Audit.should_receive(:audit_destroy).with(t,{}).and_return(2)
        t.destroy
      end
      
    end

    
    describe "#audit_destroy" do

      it "should ignore nil" do
        Audit.audit_destroy(nil).should == 0
        Audit.count.should == 0
      end
      
      it "should track changed and initialized attributes" do
        t = TestObject.create(:name => 'a')
        Audit.delete_all
        
        Audit.audit_destroy(t).should == 1
        
        all = Audit.all
        audit = all[0]
        audit.table_name.should == "appstats_test_objects"
        audit.column_type.should == nil
        audit.obj_name.should == "Appstats::TestObject"
        audit.obj_attr.should == nil
        audit.obj_id.should == t.id
        audit.action.should == "destroyed"
        audit.old_value.should == nil
        audit.new_value.should == nil
        audit.old_value_full.should == nil
        audit.new_value_full.should == nil
      end
      
      it "should do the same on :except" do
        t = TestObject.create(:name => 'a')
        Audit.delete_all
        Audit.audit_destroy(t, :except => [:name]).should == 1
      end

      it "should do the same on :only" do
        t = TestObject.create(:name => 'a')
        Audit.delete_all
        Audit.audit_destroy(t, :only => [:name]).should == 1
      end

    end
    
    describe "#audit_update" do
      
      it "should ignore nil" do
        Audit.audit_update(nil).should == 0
        Audit.count.should == 0
      end
      
      it "should be filterable on :except" do
        t = TestObject.create(:name => 'a')
        Audit.delete_all
        
        t.name = 'b'
        t.last_name = 'c'
        Audit.audit_update(t, :except => [:name]).should == 1

        all = Audit.all
        audit = all[0]
        audit.table_name.should == "appstats_test_objects"
        audit.column_type.should == "varchar(255)"
        audit.obj_name.should == "Appstats::TestObject"
        audit.obj_attr.should == 'last_name'
      end

      it "should be filterable on :only" do
        t = TestObject.create(:name => 'a')
        Audit.delete_all
        
        t.name = 'b'
        t.last_name = 'c'
        Audit.audit_update(t, :only => [:name]).should == 1

        all = Audit.all
        audit = all[0]
        audit.table_name.should == "appstats_test_objects"
        audit.column_type.should == "varchar(255)"
        audit.obj_name.should == "Appstats::TestObject"
        audit.obj_attr.should == 'name'
      end      
      
      it "should track changed and initialized attributes" do
        t = TestObject.create(:name => 'a')
        Audit.delete_all
        
        t.name = 'b'
        t.last_name = 'c'
        Audit.audit_update(t).should == 2
        
        all = Audit.all
        audit = all[0]
        audit.table_name.should == "appstats_test_objects"
        audit.column_type.should == "varchar(255)"
        audit.obj_name.should == "Appstats::TestObject"
        audit.obj_attr.should == 'name'
        audit.obj_id.should == t.id
        audit.action.should == "updated"
        audit.old_value.should == 'a'
        audit.new_value.should == 'b'
        audit.old_value_full.should == 'a'
        audit.new_value_full.should == 'b'

        audit = all[1]
        audit.table_name.should == "appstats_test_objects"
        audit.column_type.should == "varchar(255)"
        audit.obj_name.should == "Appstats::TestObject"
        audit.obj_attr.should == 'last_name'
        audit.obj_id.should == t.id
        audit.action.should == "updated"
        audit.old_value.should == nil
        audit.new_value.should == 'c'
        audit.old_value_full.should == nil
        audit.new_value_full.should == 'c'
        
      end
      
      
    end
    
    describe "#audit_create" do
      
      it "should ignore nil" do
        Audit.audit_create(nil).should == 0
        Audit.count.should == 0
      end
      
      it "should be filterable on :except" do
        t = TestObject.create(:name => 'a')
        Audit.delete_all

        Audit.audit_create(t, :except => [:name]).should == 4
        Audit.count.should == 4
      end

      it "should be filterable on :only" do
        t = TestObject.create(:name => 'a')
        Audit.delete_all

        Audit.audit_create(t, :only => [:name]).should == 2
        Audit.count.should == 2
        
        all = Audit.all
        audit = all[0]
        audit.table_name.should == "appstats_test_objects"
        audit.obj_name.should == "Appstats::TestObject"
        audit.obj_attr.should == nil

        audit = all[1]
        audit.table_name.should == "appstats_test_objects"
        audit.obj_name.should == "Appstats::TestObject"
        audit.obj_attr.should == 'name'
      end

      it "should store all non nil properties on create" do
        t = TestObject.create(:name => 'a')
        Audit.delete_all

        Audit.audit_create(t).should == 5
        Audit.count.should == 5
        
        all = Audit.all
        audit = all[0]
        audit.table_name.should == "appstats_test_objects"
        audit.obj_name.should == "Appstats::TestObject"
        audit.obj_attr.should == nil
        audit.obj_id.should == t.id
        audit.action.should == "created"
        audit.old_value.should == nil
        audit.new_value.should == nil
        audit.old_value_full.should == nil
        audit.new_value_full.should == nil

        audit = all[1]
        audit.table_name.should == "appstats_test_objects"
        audit.obj_name.should == "Appstats::TestObject"
        audit.obj_attr.should == 'name'
        audit.obj_id.should == t.id
        audit.action.should == "created"
        audit.old_value.should == nil
        audit.new_value.should == 'a'
        audit.old_value_full.should == nil
        audit.new_value_full.should == 'a'

        audit = all[2]
        audit.table_name.should == "appstats_test_objects"
        audit.obj_name.should == "Appstats::TestObject"
        audit.obj_attr.should == 'created_at'
        audit.obj_id.should == t.id
        audit.action.should == "created"
        audit.old_value.should == nil
        audit.new_value.should == t.created_at.strftime("%Y-%m-%d %H:%M:%S")
        audit.old_value_full.should == nil
        audit.new_value_full.should == t.created_at.strftime("%Y-%m-%d %H:%M:%S")

        audit = all[3]
        audit.table_name.should == "appstats_test_objects"
        audit.obj_name.should == "Appstats::TestObject"
        audit.obj_attr.should == 'updated_at'
        audit.obj_id.should == t.id
        audit.action.should == "created"
        audit.old_value.should == nil
        audit.new_value.should == t.created_at.strftime("%Y-%m-%d %H:%M:%S")
        audit.old_value_full.should == nil
        audit.new_value_full.should == t.created_at.strftime("%Y-%m-%d %H:%M:%S")
      end
      
    end


  end
end