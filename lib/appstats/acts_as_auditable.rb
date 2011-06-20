module ActsAsAuditable

  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods

    def acts_as_auditable(options = {})
      self.cattr_accessor :auditable_options

      class_eval <<-EOV
         include ActsAsAuditable::InstanceMethods
      
         after_create :audit_create
         after_destroy :audit_destroy
         after_update :audit_update
      EOV
      
      acts_as_auditable_options(options)
    end

    def acts_as_auditable_options(options = {})
      self.auditable_options = options
    end    
  end

  module InstanceMethods

    def audit_create
      Appstats::Audit.audit_create(self,self.class.auditable_options)
    end
    
    def audit_destroy
      Appstats::Audit.audit_destroy(self,self.class.auditable_options)
    end
    
    def audit_update
      Appstats::Audit.audit_update(self,self.class.auditable_options)
    end

  end
end       

ActiveRecord::Base.class_eval { include ActsAsAuditable }