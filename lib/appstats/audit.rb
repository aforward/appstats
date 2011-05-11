
module Appstats
  class Audit < ActiveRecord::Base
    set_table_name "appstats_audits"
    
    attr_accessible :table_name, :column_type, :obj_name, :obj_attr, :obj_type, :obj_id, :action, :old_value, :new_value, :old_value_full, :new_value_full
  
    
    def self.audit_create(obj, options = {})
      count = 0
      return count if obj.nil?
      table_name = obj.class.table_name
      obj_name = obj.class.name

      count += save_audit(obj, { :action => "created"}, options)
      obj.attributes.each do |obj_attr,new_value|
        next if new_value.nil?
        old_value = nil
        count += save_audit(obj, { :action => "created", :obj_attr => obj_attr, :old_value => old_value, :new_value => new_value }, options)
      end
      count
    end
    
    def self.audit_update(obj, options = {})
      count = 0
      return count if obj.nil?

      obj.changed_attributes.each do |obj_attr,old_value|
        new_value = obj.send("#{obj_attr}")
        count += save_audit(obj, { :action => "updated", :obj_attr => obj_attr, :old_value => old_value, :new_value => new_value}, options)
      end
      count
    end

    def self.audit_destroy(obj, options = {})
      count = save_audit(obj, { :action => "destroyed" }, options)
      count
    end

    private
    
      def self.save_audit(obj,custom_fields,options = {})
        return 0 if obj.nil?

        if custom_fields.key?(:obj_attr)
          obj_attr = custom_fields[:obj_attr]
          return 0 if (options.key?(:except) && options[:except].include?(obj_attr.to_sym))
          return 0 if (options.key?(:only) && !options[:only].include?(obj_attr.to_sym))
        end

        column_type = custom_fields.key?(:obj_attr) ? obj.class.columns_hash[custom_fields[:obj_attr]].sql_type : nil
        obj_type = custom_fields.key?(:obj_attr) ? obj.class.columns_hash[custom_fields[:obj_attr]].type : nil
        default_fields = { :table_name => obj.class.table_name, :column_type => column_type, :obj_type => obj_type, :obj_name => obj.class.name, :obj_id => obj.id, :old_value_full => custom_fields[:old_value], :new_value_full => custom_fields[:new_value] }
        Audit.create(default_fields.merge(custom_fields))
        1
      end

  
  end
end