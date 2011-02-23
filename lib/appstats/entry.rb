
module Appstats
  class Entry < ActiveRecord::Base
    set_table_name "appstats_entries"
    
    has_many :contexts, :table_name => 'appstats_contexts', :foreign_key => 'appstats_entry_id', :order => 'context_key'
    belongs_to :log_collector, :foreign_key => "appstats_log_collector_id"
    
    attr_accessible :action, :occurred_at, :raw_entry

    before_destroy :remove_dependencies
  
    def occurred_at=(value)
      self[:occurred_at] = value
      if value.nil?
        self[:year] = nil
        self[:month] = nil
        self[:day] = nil
        self[:hour] = nil
        self[:min] = nil
        self[:sec] = nil
        self[:week] = nil
        self[:quarter] = nil
      else
        self[:year] = value.year
        self[:month] = value.month
        self[:day] = value.day
        self[:hour] = value.hour
        self[:min] = value.min
        self[:sec] = value.sec
        self[:week] = EntryDate.calculate_week_of(value)
        self[:quarter] = EntryDate.calculate_quarter_of(value)
      end
    end
  
    def to_s
      return "No Entry" if action.nil? || action == ''
      return action if occurred_at.nil?
      "#{action} at #{occurred_at.strftime('%Y-%m-%d %H:%M:%S')}"
    end
    
    def self.create_from_logger_file(filename)
      return false if filename.nil?
      return false unless File.exists?(filename)
      File.open(filename,"r").readlines.each do |line|
        create_from_logger_string(line.strip)
      end
      true
    end
    
    def self.create_from_logger_string(action_and_contexts)
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
  
    def self.create_from_logger(action,contexts = {})
      return false if action.nil? || action.blank?
      create_from_logger_string(Logger.entry_to_s(action,contexts))
    end
    
    private
    
      def remove_dependencies
        contexts.each do |context|
          context.destroy
        end
      end
  
  end
end