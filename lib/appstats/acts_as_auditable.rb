module ActsAsAuditable

  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods

    def acts_as_auditable(options = {})

      class_eval <<-EOV
         include ActsAsAuditable::InstanceMethods
      
         after_create :audit_create
         after_destroy :audit_destroy
         after_update :audit_update
      EOV
      
    end
    
  end

  module InstanceMethods

    def audit_create
      Appstats::Audit.audit_create(self)
    end
    
    def audit_destroy
      Appstats::Audit.audit_destroy(self)
    end
    
    def audit_update
      Appstats::Audit.audit_update(self)
    end

  end
end       

ActiveRecord::Base.class_eval { include ActsAsAuditable }