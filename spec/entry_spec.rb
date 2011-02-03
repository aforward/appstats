require 'spec_helper'

module Appstats
  describe Entry do

    before(:each) do
      @time = Time.parse('2010-01-02 10:20:30')
      @entry = Appstats::Entry.new
      Time.stub!(:now).and_return(@time)
    end

    describe "#initialize" do

      it "should set action to nil" do
        @entry.action.should == nil
      end

      it "should set occurred_at to nil" do
        @entry.occurred_at.should == nil
      end
      
      it "should set raw_entry to nil" do
        @entry.raw_entry.should == nil
      end
    
      it "should set on constructor" do
        entry = Appstats::Entry.new(:action => 'a', :occurred_at => @time, :raw_entry => 'b')
        entry.action.should == 'a'
        entry.occurred_at.should == @time
        entry.raw_entry.should == 'b'
      end
    
    end
    
    describe "#contexts" do
      
      it "should have none by default" do
        @entry.contexts.size.should == 0
      end
      
      it "should be able add contexts" do
        context = Appstats::Context.new(:context_key => 'a', :context_value => 'one')
        context.save.should == true
        @entry.contexts<< context
        @entry.save.should == true
        @entry.reload
        @entry.contexts.size.should == 1
        @entry.contexts[0].should == context
      end
      
      it "should alphabetize them" do
        zzz = Appstats::Context.create(:context_key => 'zzz', :context_value => 'one')
        aaa = Appstats::Context.create(:context_key => 'aaa', :context_value => 'one')
        @entry.contexts<< zzz
        @entry.contexts<< aaa
        @entry.save.should == true
        @entry.reload
        @entry.contexts.should == [aaa,zzz]
      end
      
    end

    describe "#to_s" do
    
      before(:each) do
        @entry = Appstats::Entry.new
      end
    
      it "should return no entry if no action" do
        @entry.to_s.should == 'No Entry'
        @entry.action = ''
        @entry.to_s.should == 'No Entry'
      end
      
      it "should return the action name if no date" do
        @entry.action = "Blah"
        @entry.to_s.should == 'Blah'
      end
      
      it "should return action and date if available" do
        @entry.action = "More Blah"
        @entry.occurred_at = @time
        @entry.to_s.should == "More Blah at 2010-01-02 10:20:30"
      end
      
    end
    
    
    describe "#load_from_logger" do
      
      before(:each) do
        @before_count = Entry.count
      end
      
      it "should handle nil" do
        Entry.load_from_logger(nil)
        Entry.count.should == @before_count

        Entry.load_from_logger("")
        Entry.count.should == @before_count
      end
      
      it "should create an unknown for unknown entries" do
        Entry.load_from_logger("blah")
        Entry.count.should == @before_count + 1
        entry = Entry.last
        entry.action.should == "UNKNOWN_ACTION"
        entry.raw_entry.should == "blah"
        entry.occurred_at.should == nil
      end
      
      it "should understand an entry without contexts" do
        Entry.load_from_logger("0.0.13 setup[:,=,-n] 2010-09-21 23:15:20 action=address_search")
        Entry.count.should == @before_count + 1
        entry = Entry.last
        entry.action.should == "address_search"
        entry.raw_entry.should == "0.0.13 setup[:,=,-n] 2010-09-21 23:15:20 action=address_search"
        entry.occurred_at.should == Time.parse("2010-09-21 23:15:20")
      end
      
      it "should understand contexts" do
        Entry.load_from_logger("0.0.13 setup[:,=,-n] 2010-09-21 23:15:20 action=address_filter : app_name=Market : server=Live")
        Entry.count.should == @before_count + 1
        entry = Entry.last
        entry.action.should == "address_filter"
        entry.raw_entry.should == "0.0.13 setup[:,=,-n] 2010-09-21 23:15:20 action=address_filter : app_name=Market : server=Live"
        entry.occurred_at.should == Time.parse("2010-09-21 23:15:20")
        entry.contexts.size.should == 2
        entry.contexts[0].context_key = "app_name"
        entry.contexts[0].context_value = "Market"
        entry.contexts[1].context_key = "server"
        entry.contexts[1].context_value = "Live"
      end
      
    end
    
  end
end