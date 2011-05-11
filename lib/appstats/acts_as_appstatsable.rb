module ActsAsAppstatsable

  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods

    def acts_as_appstatsable(options = {})
      self.cattr_accessor :appstats_after_create, :appstats_after_destroy, :appstats_after_update
      
      class_eval <<-EOV
         include ActsAsAppstatsable::InstanceMethods

         after_create :track_create
         after_destroy :track_destroy
         after_update :track_update
      EOV
      
      acts_as_appstatsable_options(options)
    end
    
    def acts_as_appstatsable_options(options = {})
      if !options[:only].nil?
        self.appstats_after_create = options[:only].include?(:create)
        self.appstats_after_destroy = options[:only].include?(:destroy)
        self.appstats_after_update = options[:only].include?(:update)
      elsif !options[:except].nil?
        self.appstats_after_create = !options[:except].include?(:create)
        self.appstats_after_destroy = !options[:except].include?(:destroy)
        self.appstats_after_update = !options[:except].include?(:update)
      else
        self.appstats_after_create = true
        self.appstats_after_destroy = true
        self.appstats_after_update = true
      end      
    end
     
  end

  module InstanceMethods

    def track_create
      return false unless self.appstats_after_create
      track('object-created', :class_name => self.class.name, :class_id => self.id, :details => self.to_s)
    end

    def track_destroy
      return false unless self.appstats_after_destroy
      track('object-destroyed', :class_name => self.class.name, :class_id => self.id, :details => self.to_s)
    end

    def track_update
      return false unless self.appstats_after_update
      track('object-updated', :class_name => self.class.name, :class_id => self.id, :details => self.to_s)
    end

    def track(action,contexts)
      begin
        Appstats::Logger.entry(action,contexts)
        true
      rescue Exception => e
        Appstats::Logger.exception_entry(e,:on => action)
        false
      end
    end
    
  end
end       

ActiveRecord::Base.class_eval { include ActsAsAppstatsable }