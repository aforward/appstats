
module Appstats
  class Audit < ActiveRecord::Base
    self.table_name = "appstats_audits"
    establish_connection "appstats_#{Rails.env}" if configurations.keys.include?("appstats_#{Rails.env}")
    
    attr_accessible :table_name, :column_type, :obj_name, :obj_attr, :obj_type, :obj_id, :action, :old_value, :new_value, :old_value_full, :new_value_full
  
    
    def self.audit_create(obj, options = {})
      count = 0
      return count unless auditable?(obj)
      
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
      return count unless auditable?(obj)

      obj.changed_attributes.each do |obj_attr,old_value|
        new_value = obj.send("#{obj_attr}")
        count += save_audit(obj, { :action => "updated", :obj_attr => obj_attr, :old_value => old_value, :new_value => new_value}, options)
      end
      count
    end

    def self.audit_destroy(obj, options = {})
      count = 0
      return count unless auditable?(obj)
      count += save_audit(obj, { :action => "destroyed" }, options)
      count
    end

    private
      
      def self.auditable?(obj)
        return false if obj.nil?
        return false if obj.class == Appstats::Audit # cannot audit yourself - infinite recursion issues
        true
      end
    
      def self.save_audit(obj,custom_fields,options = {})
        if custom_fields.key?(:obj_attr)
          obj_attr = custom_fields[:obj_attr]
          return 0 if (options.key?(:except) && options[:except].include?(obj_attr.to_sym))
          return 0 if (options.key?(:only) && !options[:only].include?(obj_attr.to_sym))
        end
        
        column_data = obj.class.columns_hash[custom_fields[:obj_attr]]
        column_type = column_data.nil? ? nil : column_data.sql_type
        obj_type = column_type.nil? ? nil : column_data.type

        default_fields = { :table_name => obj.class.table_name, :column_type => column_type, :obj_type => obj_type, :obj_name => obj.class.name, :obj_id => obj.id, :old_value_full => custom_fields[:old_value], :new_value_full => custom_fields[:new_value] }
        Audit.create(default_fields.merge(custom_fields))
        1
      end

  
  end
end