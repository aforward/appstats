require 'spec_helper'

module Appstats
  describe ContextKey do

    before(:each) do
      Appstats::Context.delete_all
      Appstats::ContextKey.delete_all
      @context_key = Appstats::ContextKey.new
    end
    
    describe "#initialize" do

      it "should set name to nil" do
        @context_key.name.should == nil
      end

      it "should set status to nil" do
        @context_key.status.should == nil
      end
      
      it "should set on constructor" do
        context_key = Appstats::ContextKey.new(:name => 'a', :status => 'c')
        context_key.name.should == 'a'
        context_key.status.should == 'c'
      end
    
    end
    
    describe "#update_context_keys" do
      
      it "should do nothing if no events" do
        Appstats::ContextKey.update_context_keys.should == 0
        Appstats::ContextKey.count.should == 0
      end
      
      it "should add entry context_key names" do
        Appstats::Context.create(:context_key => 'a')
        Appstats::ContextKey.update_context_keys.should == 1
        Appstats::ContextKey.count.should == 1
        
        context_key = Appstats::ContextKey.last
        context_key.name = 'a'
        context_key.status = 'derived'
      end
      
    end
    
    describe "#rename" do
    
      it "should update the ContextKey" do
        context_key = Appstats::ContextKey.create(:name => 'a', :status => 'c')
        Appstats::ContextKey.rename('a','aaa')
        context_key.reload
        context_key.name.should == 'aaa'
      end

      it "should update all Contexts" do
        context = Appstats::Context.create(:context_key => 'b')
        context2 = Appstats::Context.create(:context_key => 'notb')
        Appstats::ContextKey.rename('b','bbb')
        context.reload and context2.reload
        
        context.context_key.should == 'bbb'
        context2.context_key.should == 'notb'
      end
      
      it "should update ActionContextKeys" do
        action = Appstats::ActionContextKey.create(:action_name => 'a', :context_key => 'b', :status => 'c')
        action2 = Appstats::ActionContextKey.create(:action_name => 'a', :context_key => 'notb', :status => 'c')

        Appstats::ContextKey.rename('b','bbb')
        action.reload and action2.reload
        
        action.context_key.should == 'bbb'
        action2.context_key.should == 'notb'
      end
    
     
    end
    

  end
end