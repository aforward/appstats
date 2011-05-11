
module Appstats
  class Audit < ActiveRecord::Base
    set_table_name "appstats_audits"
    
    attr_accessible :table_name, :column_type, :obj_name, :obj_attr, :obj_type, :obj_id, :action, :old_value, :new_value, :old_value_full, :new_value_full
  
    
    def self.audit_create(obj)
      count = 0
      return count if obj.nil?
      table_name = obj.class.table_name
      obj_name = obj.class.name


      save_audit(obj, :action => "created")
      count += 1
      obj.attributes.each do |obj_attr,new_value|
        next if new_value.nil?
        old_value = nil
        save_audit(obj, :action => "created", :obj_attr => obj_attr, :old_value => old_value, :new_value => new_value)
        count += 1
      end
      count
    end
    
    def self.audit_update(obj)
      count = 0
      return count if obj.nil?

      obj.changed_attributes.each do |obj_attr,old_value|
        new_value = obj.send("#{obj_attr}")
        save_audit(obj, :action => "updated", :obj_attr => obj_attr, :old_value => old_value, :new_value => new_value)
        count += 1
      end
      count
    end

    def self.audit_destroy(obj)
      count = 0
      return count if obj.nil?
      count += 1
      save_audit(obj, :action => "destroyed")
      count
    end

    private
    
      def self.save_audit(obj,custom_fields = {})
        column_type = custom_fields.key?(:obj_attr) ? obj.class.columns_hash[custom_fields[:obj_attr]].sql_type : nil
        obj_type = custom_fields.key?(:obj_attr) ? obj.class.columns_hash[custom_fields[:obj_attr]].type : nil
        default_fields = { :table_name => obj.class.table_name, :column_type => column_type, :obj_type => obj_type, :obj_name => obj.class.name, :obj_id => obj.id, :old_value_full => custom_fields[:old_value], :new_value_full => custom_fields[:new_value] }
        Audit.create(default_fields.merge(custom_fields))
      end

  
  end
end