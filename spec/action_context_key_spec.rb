require 'spec_helper'

module Appstats
  describe ActionContextKey do

    before(:each) do
      Appstats::Entry.delete_all
      Appstats::Context.delete_all
      Appstats::ActionContextKey.delete_all
      @action = Appstats::ActionContextKey.new
    end
    
    
    
    describe "#initialize" do

      it "should set action_name to nil" do
        @action.action_name.should == nil
      end

      it "should set context_key to nil" do
        @action.context_key.should == nil
      end

      it "should set status to nil" do
        @action.status.should == nil
      end
      
      it "should set on constructor" do
        action = Appstats::ActionContextKey.new(:action_name => 'a', :context_key => 'b', :status => 'c')
        action.action_name.should == 'a'
        action.context_key.should == 'b'
        action.status.should == 'c'
      end
    
    end

    describe "#update_action_context_keys" do
      
      it "should do nothing if no events" do
        Appstats::ActionContextKey.update_action_context_keys.should == 0
        Appstats::ActionContextKey.count.should == 0
      end
      
      it "should ignore actions without any contexts" do
        Appstats::Entry.create_from_logger('a')
        Appstats::ActionContextKey.update_action_context_keys.should == 0
        Appstats::ActionContextKey.count.should == 0
        
      end
      
      it "should add entry action / context names" do
        Appstats::Entry.create_from_logger('a',:blah => "x")
        Appstats::ActionContextKey.update_action_context_keys.should == 1
        Appstats::ActionContextKey.count.should == 1
        
        action = Appstats::ActionContextKey.last
        action.action_name = 'a'
        action.context_key = 'blah'
        action.status = 'derived'
      end

      it "should ignore existing entries action / context names" do
        Appstats::Entry.create_from_logger('a',:blah => "x")
        Appstats::ActionContextKey.update_action_context_keys.should == 1
        Appstats::ActionContextKey.update_action_context_keys.should == 0
      end

      it "should ignore duplicates" do
        Appstats::Entry.create_from_logger('a',:blah => "x")
        Appstats::Entry.create_from_logger('a',:blah => "y")
        Appstats::ActionContextKey.update_action_context_keys.should == 1
        Appstats::ActionContextKey.count.should == 1
      end
      
      
    end


  end
end