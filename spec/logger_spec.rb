require 'spec_helper'

module Appstats
  describe Logger do
    
    before(:each) do
      Appstats::Logger.reset
      Time.stub!(:now).and_return(Time.parse('2010-09-21 23:15:20'))
    end
    
    after(:each) do
      File.delete(Appstats::Logger.filename) if File.exists?(Appstats::Logger.filename)
    end
    
    describe "#initialize" do
      
    end
    
    describe "#reset" do
      
      it "should unset filename_template" do
        Appstats::Logger.filename_template = "blah"
        Appstats::Logger.reset
        Appstats::Logger.filename_template.should == "appstats"
      end
      
      it "should unset default contexts" do
        Appstats::Logger.default_contexts[:blah] = "x"
        Appstats::Logger.reset
        Appstats::Logger.default_contexts.empty?.should be_true
      end
      
    end
    
    describe "#filename" do

      it "should be based on daily timestamp" do
        Appstats::Logger.filename.should == 'appstats_2010-09-21.log'
      end
      
      it "should support full paths" do
        Appstats::Logger.filename_template = "/a/b/appstats"
        Appstats::Logger.filename.should == '/a/b/appstats_2010-09-21.log'
      end
      
    end
        
    describe "#filename_template" do

      it "should default to appstats" do
        Appstats::Logger.filename_template.should == "appstats"
      end
      
      it "should be settable" do
        Appstats::Logger.filename_template = "blah"
        Appstats::Logger.filename_template.should == "blah"
      end
      
    end
    
    describe "#raw_read" do
      
      it "should return empty if file does not exist" do
        File.exists?(Appstats::Logger.filename).should == false
        Appstats::Logger.raw_read.should == []
      end
      
      it "should read all data" do
        Appstats::Logger.raw_write("abc")
        Appstats::Logger.raw_write("def")
        Appstats::Logger.raw_read.should == ["abc","def"]
      end
      
    end
    
    describe "#raw_write" do
      
      it "should create the file if it doesn't exist" do
        File.exists?("appstats_2010-09-21.log").should == false
        Appstats::Logger.raw_write("abc")
        File.exists?("appstats_2010-09-21.log").should == true
      end
      
      it "should save text as is" do
        Appstats::Logger.raw_write("abc")
        Appstats::Logger.raw_write("def")
        Appstats::Logger.raw_read.should == ["abc","def"]
      end
      
    end
    
    describe "#now" do
      
      it "should return a formatted date" do
        Appstats::Logger.now.should == "2010-09-21 23:15:20"
      end
      
    end

    describe "#today" do
      
      it "should return a formatted date" do
        Appstats::Logger.today.should == "2010-09-21"
      end
      
    end

    describe "#entry" do
      
      it "should outlien the to_s" do
        Appstats::Logger.stub!(:entry_to_s).with("address_search",{}).and_return("entry_to_s called")
        Appstats::Logger.entry("address_search")
        Appstats::Logger.raw_read.should == ["entry_to_s called"]
      end

    end
    
    describe "#entry_to_hash" do
    
       it "should handle nil" do
         Appstats::Logger.entry_to_hash(nil).should == { :action => "UNKNOWN_ACTION", :raw_input => nil }
       end
    
       it "should fail softly with invalid data" do
         Appstats::Logger.entry_to_hash("blah").should == { :action => "UNKNOWN_ACTION", :raw_input => "blah" }
       end
    
       it "should handle a statistics entry" do
         expected = { :action => "address_search", :timestamp => "2010-09-21 23:15:20" }
         actual = Appstats::Logger.entry_to_hash("0.0.9 setup[:,=,-n] 2010-09-21 23:15:20 action=address_search")
         actual.should == expected
       end
       
       it "should handle contexts" do
         expected = { :action => "address_filter", :timestamp => "2010-09-21 23:15:20", :server => "Live", :app_name => 'Market' }
         actual = Appstats::Logger.entry_to_hash("0.0.9 setup[:,=,-n] 2010-09-21 23:15:20 action=address_filter : app_name=Market : server=Live")
         actual.should == expected
       end
    
       it "should handle actions with the delimiter (and change the delimiter)" do
         expected = { :action => "address:=search-n", :timestamp => "2010-09-21 23:15:20" }
         actual = Appstats::Logger.entry_to_hash("0.0.9 setup[::,==,--n] 2010-09-21 23:15:20 action==address:=search-n")
         actual.should == expected
    
         expected = { :action => "address::search==--n", :timestamp => "2010-09-21 23:15:20" }
         actual = Appstats::Logger.entry_to_hash("0.0.9 setup[:::,===,---n] 2010-09-21 23:15:20 action===address::search==--n")
         actual.should == expected
       end
    
       it "should handle contexts with the delimiter (and change the delimiter)" do
         expected = { :action => "address", :timestamp => "2010-09-21 23:15:20", :server => "market:eval=-n" }
         actual = Appstats::Logger.entry_to_hash("0.0.9 setup[::,==,--n] 2010-09-21 23:15:20 action==address :: server==market:eval=-n")
         actual.should == expected
       end
    
       
     end
    
    describe "#entry_to_s" do
      
      it "should handle a statistics entry" do
        expected = "0.0.9 setup[:,=,-n] 2010-09-21 23:15:20 action=address_search"
        actual = Appstats::Logger.entry_to_s("address_search")
        actual.should == expected
      end
      
      it "should handle default contexts" do
        Appstats::Logger.default_contexts[:app_name] = "market"
        expected = "0.0.9 setup[:,=,-n] 2010-09-21 23:15:20 action=address_search : app_name=market"
        actual = Appstats::Logger.entry_to_s("address_search")
        actual.should == expected
      end
      
      it "should handle contexts (and sort them by symbol)" do
        expected = "0.0.9 setup[:,=,-n] 2010-09-21 23:15:20 action=address_filter : app_name=Market : server=Live"
        actual = Appstats::Logger.entry_to_s("address_filter", { :server => "Live", :app_name => 'Market' })
        actual.should == expected
      end

      it "should handle actions with the delimiter (and change the delimiter)" do
        expected = "0.0.9 setup[::,==,--n] 2010-09-21 23:15:20 action==address:=search-n"
        actual = Appstats::Logger.entry_to_s("address:=search-n")
        actual.should == expected

        expected = "0.0.9 setup[:::,===,---n] 2010-09-21 23:15:20 action===address::search==--n"
        actual = Appstats::Logger.entry_to_s("address::search==--n")
        actual.should == expected
      end

      it "should handle contexts with the delimiter (and change the delimiter)" do
        expected = "0.0.9 setup[::,==,--n] 2010-09-21 23:15:20 action==address :: server==market:eval=-n"
        actual = Appstats::Logger.entry_to_s("address", :server => 'market:eval=-n')
        actual.should == expected
      end
      
    end
    

  end
end