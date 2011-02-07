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
    
    describe "#load_from_logger_file" do
      
      before(:each) do
        @before_count = Entry.count
        Appstats::Logger.reset
        Time.stub!(:now).and_return(Time.parse('2010-09-21 23:15:20'))
      end

      after(:each) do
        File.delete(Appstats::Logger.filename) if File.exists?(Appstats::Logger.filename)
      end

      it "should handle nil" do
        Entry.load_from_logger_file(nil).should == false
        Entry.count.should == @before_count
        Entry.count.should == @before_count
      end
      
      it "should handle unknown files" do
        File.exists?("should_not_exist.txt").should == false
        Entry.load_from_logger_file("should_not_exist.txt").should == false
        Entry.count.should == @before_count
      end
      
      it "should handle appstat files" do
        Appstats::Logger.entry("test_action")
        Appstats::Logger.entry("another_test_action")
        Entry.load_from_logger_file(Appstats::Logger.filename).should == true
        Entry.count.should == @before_count + 2
        Entry.last.action.should == "another_test_action"
      end
      
    end
    
    
    describe "#load_from_logger_entry" do
      
      before(:each) do
        @before_count = Entry.count
      end
      
      it "should handle nil" do
        Entry.load_from_logger_entry(nil).should == false
        Entry.count.should == @before_count

        Entry.load_from_logger_entry("").should == false
        Entry.count.should == @before_count
      end
      
      it "should create an unknown for unknown entries" do
        entry = Entry.load_from_logger_entry("blah")
        Entry.count.should == @before_count + 1
        entry.action.should == "UNKNOWN_ACTION"
        entry.raw_entry.should == "blah"
        entry.occurred_at.should == nil
      end
      
      it "should understand an entry without contexts" do
        entry = Entry.load_from_logger_entry("0.0.15 setup[:,=,-n] 2010-09-21 23:15:20 action=address_search")
        Entry.count.should == @before_count + 1
        entry.action.should == "address_search"
        entry.raw_entry.should == "0.0.15 setup[:,=,-n] 2010-09-21 23:15:20 action=address_search"
        entry.occurred_at.should == Time.parse("2010-09-21 23:15:20")
      end
      
      it "should understand contexts" do
        entry = Entry.load_from_logger_entry("0.0.15 setup[:,=,-n] 2010-09-21 23:15:20 action=address_filter : app_name=Market : server=Live")
        Entry.count.should == @before_count + 1
        entry.action.should == "address_filter"
        entry.raw_entry.should == "0.0.15 setup[:,=,-n] 2010-09-21 23:15:20 action=address_filter : app_name=Market : server=Live"
        entry.occurred_at.should == Time.parse("2010-09-21 23:15:20")
        entry.contexts.size.should == 2
        entry.contexts[0].context_key = "app_name"
        entry.contexts[0].context_value = "Market"
        entry.contexts[1].context_key = "server"
        entry.contexts[1].context_value = "Live"
      end
      
    end
   
    describe "#log_collector" do
      
      before(:each) do
        @log_collector = Appstats::LogCollector.new(:host => "a")
        @log_collector.save.should == true
      end
      
      it "should have a log_collector" do
        @entry.log_collector.should == nil
        @entry.log_collector = @log_collector
        @entry.save.should == true
        @entry.reload
        @entry.log_collector.should == @log_collector
        
        @entry = Entry.last
        @entry.log_collector.should == @log_collector
      end
      
    end    

  end
end