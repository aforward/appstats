require 'spec_helper'

describe ActsAsAuditable do

  before(:each) do
    Time.stub!(:now).and_return(Time.parse('2010-09-21 23:15:20'))
    Appstats::TestObject.acts_as_auditable_options
    Appstats::Audit.delete_all
  end

  after(:all) do
    Appstats::TestObject.acts_as_auditable_options
  end

  describe "should be settable in the options" do

    describe "create" do

      it "should only track included options" do
        Appstats::TestObject.acts_as_auditable_options(:only => [:name])
        @obj = Appstats::TestObject.create(:name => "x")
        Appstats::Audit.count.should == 2
      end

      it "should exclude track excluded options" do
        Appstats::TestObject.acts_as_auditable_options(:except => [:name])
        @obj = Appstats::TestObject.create(:name => "x")
        Appstats::Audit.count.should == 4
      end    

      it "should default to all " do
        Appstats::TestObject.acts_as_auditable_options
        @obj = Appstats::TestObject.create(:name => "x")
        Appstats::Audit.count.should == 5
      end
            
    end

    describe "update" do

      before(:each) do
        @obj = Appstats::TestObject.create(:name => "x")
        Appstats::Audit.delete_all
        @obj.name = "y"
        @obj.last_name = "z"
        @obj.blah_string = "x"
      end

      it "should only track included options" do
        Appstats::TestObject.acts_as_auditable_options(:only => [:name])
        @obj.save
        Appstats::Audit.count.should == 1
      end

      it "should exclude track excluded options" do
        Appstats::TestObject.acts_as_auditable_options(:except => [:name])
        @obj.save
        Appstats::Audit.count.should == 2
      end    

      it "should default to all " do
        @obj.save
        Appstats::Audit.count.should == 3
      end
      
    end

  end

  
  # describe "default behaviour" do
  # 
  #   it "should track after_save" do
  #     @obj = Appstats::TestObject.create(:name => "x")
  #     Appstats::Logger.raw_read.last.should == Appstats::Logger.entry_to_s("object-created", :class_name => "Appstats::TestObject", :class_id => @obj.id, :details => "[x]")
  #   end
  # 
  #   it "should track after_destroy" do
  #     Appstats::TestObject.acts_as_auditable(:only => [:destroy])
  #     @obj = Appstats::TestObject.create(:name => "x")
  #     @obj.destroy
  #     Appstats::Logger.raw_read.last.should == Appstats::Logger.entry_to_s("object-destroyed", :class_name => "Appstats::TestObject", :class_id => @obj.id, :details => "[x]")
  #   end
  # 
  #   it "should track after_update" do
  #     Appstats::TestObject.acts_as_auditable(:only => [:update])
  #     @obj = Appstats::TestObject.create(:name => "x")
  #     @obj.name = "y"
  #     @obj.save
  #     Appstats::Logger.raw_read.last.should == Appstats::Logger.entry_to_s("object-updated", :class_name => "Appstats::TestObject", :class_id => @obj.id, :details => "[y]")
  #   end
  # 
  # 
  #   it "should handle exceptions" do
  #     @cheating = Appstats::TestObject.create(:name => "y")
  #     Appstats::Logger.stub!(:entry).with("object-created", :class_name => "Appstats::TestObject", :class_id => @cheating.id + 1, :details => "[x]").and_raise("something bad")
  #     @obj = Appstats::TestObject.create(:name => "x")
  #     Appstats::Logger.raw_read.last.should == Appstats::Logger.entry_to_s("appstats-exception", :on => "object-created", :error => "something bad")
  #   end
  # end

end
