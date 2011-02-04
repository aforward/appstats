
module Appstats
  class Entry < ActiveRecord::Base
    set_table_name "appstats_entries"
    
    has_many :contexts, :table_name => 'appstats_contexts', :foreign_key => 'appstats_entry_id', :order => 'context_key'
    attr_accessible :action, :occurred_at, :raw_entry
  
    def to_s
      return "No Entry" if action.nil? || action == ''
      return action if occurred_at.nil?
      "#{action} at #{occurred_at.strftime('%Y-%m-%d %H:%M:%S')}"
    end
    
    def self.load_from_logger_file(filename)
      return false if filename.nil?
      return false unless File.exists?(filename)
      File.open(filename,"r").readlines.each do |line|
        load_from_logger_entry(line.strip)
      end
      true
    end
    
    def self.load_from_logger_entry(action_and_contexts)
      return false if action_and_contexts.nil? || action_and_contexts == ''
      hash = Logger.entry_to_hash(action_and_contexts)
      entry = Appstats::Entry.new(:action => hash[:action], :raw_entry => action_and_contexts)
      entry.occurred_at = Time.parse(hash[:timestamp]) unless hash[:timestamp].nil?
      hash.each do |key,value|
        next if key == :action
        next if key == :timestamp
        context = Appstats::Context.create(:context_key => key, :context_value => value)
        entry.contexts<< context
      end
      entry.save
      entry
    end
  
  end
end