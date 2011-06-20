require 'spec_helper'

module Appstats
  describe Action do

    before(:each) do
      Appstats::Entry.delete_all
      Appstats::Action.delete_all
      @action = Appstats::Action.new
    end
    
    describe "#initialize" do

      it "should set name to nil" do
        @action.name.should == nil
      end

      it "should set plural_name to nil" do
        @action.plural_name.should == nil
      end

      it "should set status to nil" do
        @action.status.should == nil
      end
      
      it "should set on constructor" do
        action = Appstats::Action.new(:name => 'a', :plural_name => 'b', :status => 'c')
        action.name.should == 'a'
        action.plural_name.should == 'b'
        action.status.should == 'c'
      end
    
    end
    
    describe "#update_actions" do
      
      it "should do nothing if no events" do
        Appstats::Action.update_actions.should == 0
        Appstats::Action.count.should == 0
      end
      
      it "should add entry action names" do
        Appstats::Entry.create(:action => 'a')
        Appstats::Action.update_actions.should == 1
        Appstats::Action.count.should == 1
        
        action = Appstats::Action.last
        action.name = 'a'
        action.plural_name = 'as'
        action.status = 'derived'
      end
      
    end
    

  end
end