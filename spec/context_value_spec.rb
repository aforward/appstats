require 'spec_helper'

module Appstats
  describe ContextValue do

    before(:each) do
      Appstats::Context.delete_all
      Appstats::ContextValue.delete_all
      @context_value = Appstats::ContextValue.new
    end
    
    describe "#initialize" do

      it "should set name to nil" do
        @context_value.name.should == nil
      end

      it "should set status to nil" do
        @context_value.status.should == nil
      end
      
      it "should set on constructor" do
        context_value = Appstats::ContextValue.new(:name => 'a', :status => 'c')
        context_value.name.should == 'a'
        context_value.status.should == 'c'
      end
    
    end
    
    describe "#update_context_values" do
      
      it "should do nothing if no events" do
        Appstats::ContextValue.update_context_values.should == 0
        Appstats::ContextValue.count.should == 0
      end
      
      it "should add entry context_value names" do
        Appstats::Context.create(:context_value => 'a')
        Appstats::ContextValue.update_context_values.should == 1
        Appstats::ContextValue.count.should == 1
        
        context_value = Appstats::ContextValue.last
        context_value.name = 'a'
        context_value.status = 'derived'
      end
      
    end
    

  end
end