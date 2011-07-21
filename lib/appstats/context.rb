
module Appstats
  class Context < ActiveRecord::Base
    set_table_name "appstats_contexts"
    establish_connection "appstats_#{Rails.env}" if configurations.keys.include?("appstats_#{Rails.env}")
    
    belongs_to :entry, :class_name => "Appstats::Entry", :foreign_key => "appstats_entry_id"
    attr_accessible :context_key, :context_value
  
    def context_value=(value)
      self[:context_value] = value
      self[:context_int] = nil
      self[:context_float] = nil
      return if value.nil?
      as_int = value.to_i
      as_float = value.to_f
      self[:context_int] = as_int if as_int.to_s == value
      self[:context_float] = as_float if as_float.to_s == value || !self[:context_int].nil?
    end
  
    def to_s
      return "No Context" if context_key.nil? || context_key == ''
      "#{context_key}[]" if context_value.nil?
      "#{context_key}[#{context_value}]"
    end
  
  end
end