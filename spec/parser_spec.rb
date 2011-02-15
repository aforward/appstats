require 'spec_helper'

module Appstats
  describe Parser do

    before(:each) do
      @parser = Parser.new
    end
     
    describe("#initialize") do
      
      it "should set rules to nil" do
        @parser.raw_rules.should == nil
        @parser.rules.should == []
      end
      
      it "should set rules from constructor" do
        parser = Parser.new(:rules => ":name")
        parser.raw_rules.should == ":name"
        parser.rules.should == [ { :rule => :name, :stop => :end } ]
      end
      
    end
     
     
    describe "#rules" do
      
      it "should handle one variable" do
        Parser.new(:rules => ":name").rules.should == [ { :rule => :name, :stop => :end } ]
      end
    
      it "should handle many variables" do
        Parser.new(:rules => ":name :date").rules.should == [ { :rule => :name, :stop => :space }, { :rule => :date, :stop => :end } ]
      end
    
      it "should deal with colons" do
        Parser.new(:rules => ":name : :date").rules.should == [ { :rule => :name, :stop => :constant }, ":", { :rule => :date, :stop => :end } ]
      end
    
      it "should deal with constant" do
        Parser.new(:rules => "blah").rules.should == ["BLAH"]
      end
    
      it "should deal with constant and variables" do
        Parser.new(:rules => ":name blah :date").rules.should == [ { :rule => :name, :stop => :constant }, "BLAH", { :rule => :date, :stop => :end } ]
      end
    
      it "should deal with multiple constants and variables" do
        Parser.new(:rules => ":name blah more blah :date").rules.should == [ { :rule => :name, :stop => :constant }, "BLAH", "MORE", "BLAH", { :rule => :date, :stop => :end } ]
      end
      
    end
     
    describe "#constants" do
      
      it "should be empty if only variables" do
        Parser.new(:rules => ":name :blah").constants.should == [ ]
      end
    
      it "should track all constants" do
        Parser.new(:rules => ":name : :date").constants.should == [ ":" ]
      end
    
      it "should upper case constants" do
        Parser.new(:rules => "blah").constants.should == ["BLAH"]
      end
    
      it "should deal with multiple constants" do
        Parser.new(:rules => ":name = :blah and :moreblah").constants.should == ["=","AND"]
      end
    
    end
     
    describe "#parse_constant" do
    
      it "should handle nil" do
        Parser.parse_constant(nil,nil).should == [nil,nil]
        Parser.parse_constant("",nil).should == [nil,nil]
      end
    
      it "should find the constant" do
        Parser.parse_constant("= blah blah more blah ","=").should == ["=","blah blah more blah"]
      end
    
      it "should find the constants with multiple characters" do
        Parser.parse_constant("hey blah blah more blah ","hey").should == ["hey","blah blah more blah"]
      end
    
      it "should return nil if not found" do
        Parser.parse_constant("blah blah more blah ","=").should == [nil,"blah blah more blah"]
      end
    
      it "should be case insensitive" do
        Parser.parse_constant(" blah stuff on more blah stuff ","blah").should == ["blah","stuff on more blah stuff"]
        Parser.parse_constant(" BLAH stuff on more blah stuff ","blah").should == ["BLAH","stuff on more blah stuff"]
        Parser.parse_constant(" blah stuff on more blah stuff ","BLAH").should == ["blah","stuff on more blah stuff"]
      end
    
      it "should only find the first instance" do
        Parser.parse_constant("one == two","==").should == [nil,"one == two"]
      end
      
    end
     
    describe "#parse_word" do
      
      it "should handle nil" do
        Parser.parse_word(nil,nil).should == [nil,nil]
        Parser.parse_word("",nil).should == [nil,nil]
      end
    
      it "should handle :end" do
        Parser.parse_word("blah",:end).should == ["blah",nil]
        Parser.parse_word("more blah blah blah",:end).should == ["more blah blah blah",nil]
      end
    
      it "should handle :space" do
        Parser.parse_word("more blah blah blah",:space).should == ["more","blah blah blah"]
        Parser.parse_word("who dat",:space).should == ["who","dat"]
      end
      
      it "should handle :space when no more spaces" do
        Parser.parse_word("blah",:space).should == ["blah",nil]
      end
    
      it "should strip front space" do
        Parser.parse_word(" blah ",:space).should == ["blah",nil]
        Parser.parse_word(" more blah blah blah ",:space).should == ["more","blah blah blah"]
        Parser.parse_word(" who dat ",:space).should == ["who","dat"]
      end
    
      it "should on constant" do
        Parser.parse_word(" blah stuff = more blah stuff ","=").should == ["blah stuff","= more blah stuff"]
      end
    
      it "should be case insensitive" do
        Parser.parse_word(" blah stuff on more blah stuff ","on").should == ["blah stuff","on more blah stuff"]
        Parser.parse_word(" blah stuff ON more blah stuff ","on").should == ["blah stuff","ON more blah stuff"]
        Parser.parse_word(" blah stuff on more blah stuff ","ON").should == ["blah stuff","on more blah stuff"]
      end
    
      it "should grab whole string if not constant not present" do
        Parser.parse_word(" blah ","x").should == ["blah", nil]
      end
    
      it "should be able to explicitly set if you want an exact match or not" do
        Parser.parse_word(" aa bbb ","x",false).should == ["aa bbb", nil]
        Parser.parse_word(" aa bbb ","x",true).should == [nil, "aa bbb"]
    
        Parser.parse_word(" aa bbb ","bbb",false).should == ["aa", "bbb"]
        Parser.parse_word(" aa bbb ","bbb",true).should == ["aa", "bbb"]
      end
    
    
      
    end
     
    describe "#parse" do
    
      it "fails if no rules" do
        @parser.parse("blah").should == false
      end
      
      it "fails on nil" do
        parser = Parser.new(:rules => ":name")
        parser.parse(nil).should == false
      end
      
      it "passes on a simple rule" do
        parser = Parser.new(:rules => ":name")
        parser.parse("blah").should == true
        parser.raw_results.should == [ {:name => "blah"} ]
      end
          
      it "passes on several rules" do
        parser = Parser.new(:rules => ":one :two :three")
        parser.parse("a  bbb cc").should == true
        parser.raw_results.should == [ {:one => "a"}, { :two => "bbb"}, { :three => "cc" } ]
      end
          
      it "passes on combination of constants and rules" do
        parser = Parser.new(:rules => ":operation :action :date on :server where :contexts")
        parser.parse("# logins today on my.local where stuff").should == true
        parser.raw_results.should == [ {:operation => "#"}, { :action => "logins"}, { :date => "today" }, { :server => "my.local"}, { :contexts => "stuff" } ]
      end
    
      it "passes on combination of constants and rules" do
        parser = Parser.new(:rules => ":operation :action :date on :server where :contexts")
        parser.parse("# logins where stuff").should == true
        parser.raw_results.should == [ {:operation => "#"}, { :action => "logins"}, { :date => nil }, { :server => nil}, { :contexts => "stuff" } ]
      end
    
      it "should be able to skip constants" do
        parser = Parser.new(:rules => ":one aa :two bbb :three")
        parser.parse("1 bbb 3")
        parser.results.should == { :one => "1", :two => nil, :three => "3" }
      end
    
      it "should handle missing constants" do
        parser = Parser.new(:rules => ":one aa :two bbb :three")
        parser.parse("1").should == true
        parser.results.should == {:one => "1", :two => nil, :three => nil }
      end
    
      it "should handle missing constants" do
        parser = Parser.new(:rules => ":one aa :two bbb :three")
        parser.parse("1 one aa 222 ").should == true
        parser.raw_results.should == [ {:one => "1 one"}, { :two => "222"}, { :three => nil } ]
      end
      
      describe "real examples" do
        
        it "should find host" do
          parser = Appstats::Parser.new(:rules => ":operation :action :date on :host where :contexts")
          parser.parse("# logins between 2010-01-15 and 2010-01-31 on your.localnet").should == true
          parser.results.should == {:operation => "#", :action => "logins", :date => "between 2010-01-15 and 2010-01-31", :host => "your.localnet", :contexts => nil }
        end
        
      end
      
    end
  end
end