require 'spec_helper'

describe ActsAsAppstatsable do

  before(:each) do
    Time.stub!(:now).and_return(Time.parse('2010-09-21 23:15:20'))
    Appstats::Logger.reset
    Appstats::TestObject.acts_as_appstatsable_options
  end

  after(:each) do
    File.delete(Appstats::Logger.filename) if File.exists?(Appstats::Logger.filename)
  end

  describe "should be settable in the options" do

    it "should only track included options" do
      # TODO: why isn't the logger empty?!?
      start_index = Appstats::Logger.raw_read.size
      Appstats::TestObject.acts_as_appstatsable_options(:only => [:create,:destroy])
      @obj = Appstats::TestObject.create(:name => "x")
      @obj.name = "y"
      @obj.save
      @obj.destroy
      Appstats::Logger.raw_read[start_index..-1].should == [
        Appstats::Logger.entry_to_s("object-created", :class_name => "Appstats::TestObject", :class_id => @obj.id, :details => "[x]"),
        Appstats::Logger.entry_to_s("object-destroyed", :class_name => "Appstats::TestObject", :class_id => @obj.id, :details => "[y]")
      ]
    end
    
    it "should exclude track excluded options" do
      Appstats::TestObject.acts_as_appstatsable_options(:except => [:create,:destroy])
      @obj = Appstats::TestObject.create(:name => "x")
      @obj.name = "y"
      @obj.save
      @obj.destroy
      Appstats::Logger.raw_read.should == [Appstats::Logger.entry_to_s("object-updated", :class_name => "Appstats::TestObject", :class_id => @obj.id, :details => "[y]")]
    end    
  end

  describe "default behaviour" do

    it "should track after_save" do
      @obj = Appstats::TestObject.create(:name => "x")
      Appstats::Logger.raw_read.last.should == Appstats::Logger.entry_to_s("object-created", :class_name => "Appstats::TestObject", :class_id => @obj.id, :details => "[x]")
    end

    it "should track after_destroy" do
      Appstats::TestObject.acts_as_appstatsable(:only => [:destroy])
      @obj = Appstats::TestObject.create(:name => "x")
      @obj.destroy
      Appstats::Logger.raw_read.last.should == Appstats::Logger.entry_to_s("object-destroyed", :class_name => "Appstats::TestObject", :class_id => @obj.id, :details => "[x]")
    end

    it "should track after_update" do
      Appstats::TestObject.acts_as_appstatsable(:only => [:update])
      @obj = Appstats::TestObject.create(:name => "x")
      @obj.name = "y"
      @obj.save
      Appstats::Logger.raw_read.last.should == Appstats::Logger.entry_to_s("object-updated", :class_name => "Appstats::TestObject", :class_id => @obj.id, :details => "[y]")
    end


    it "should handle exceptions" do
      @cheating = Appstats::TestObject.create(:name => "y")
      Appstats::Logger.stub!(:entry).with("object-created", :class_name => "Appstats::TestObject", :class_id => @cheating.id + 1, :details => "[x]").and_raise("something bad")
      @obj = Appstats::TestObject.create(:name => "x")
      Appstats::Logger.raw_read.last.should == Appstats::Logger.entry_to_s("appstats-exception", :on => "object-created", :error => "something bad")
    end
  end

end
