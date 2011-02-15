require 'spec_helper'

module Appstats
  describe Host do

    before(:each) do
      Appstats::LogCollector.delete_all
      Appstats::Host.delete_all
      @host = Appstats::Host.new
    end
    
    describe "#initialize" do

      it "should set name to nil" do
        @host.name.should == nil
      end

      it "should set status to nil" do
        @host.status.should == nil
      end
      
      it "should set on constructor" do
        host = Appstats::Host.new(:name => 'a', :status => 'c')
        host.name.should == 'a'
        host.status.should == 'c'
      end
    
    end
    
    describe "#update_hosts" do
      
      it "should do nothing if no events" do
        Appstats::Host.update_hosts.should == 0
        Appstats::Host.count.should == 0
      end
      
      it "should add entry host names" do
        Appstats::LogCollector.create(:host => 'a')
        Appstats::Host.update_hosts.should == 1
        Appstats::Host.count.should == 1
        
        host = Appstats::Host.last
        host.name = 'a'
        host.status = 'derived'
      end
      
    end
    

  end
end