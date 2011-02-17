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
    

  end
end