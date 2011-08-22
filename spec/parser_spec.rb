require 'spec_helper'

module Appstats
  describe Parser do

    before(:each) do
      @parser = Parser.new
    end
     
    describe("#initialize") do
       
       it "should set rules to nil" do
         @parser.raw_rules.should == nil
         @parser.raw_tokenize.should == nil
         @parser.repeating.should == false
         @parser.tokenize_regex == nil
         @parser.rules.should == []
         @parser.tokenize.should == []
         @parser.constants.should == []
         @parser.constants_no_spaces.should == []
       end
      
       it "should set rules from constructor" do
         parser = Parser.new(:rules => ":name or :bust", :tokenize => "a bb c", :repeating => true)
         parser.raw_rules.should == ":name or :bust"
         parser.raw_tokenize.should == "a bb c"
         parser.repeating.should == true
         parser.rules.should == [ { :rule => :name, :stop => :constant }, "OR", { :rule => :bust, :stop => :end} ]
         parser.tokenize.should == ["\\s+A(\\s|$)","\\s+BB(\\s|$)","\\s+C(\\s|$)"]
         parser.tokenize_no_spaces.should == ["A","BB","C"]
         parser.constants.should == ["\\s+OR(\\s|$)"]
         parser.constants_no_spaces.should == ["OR"]
       end
    
       it "should tokenize multi words" do
         parser = Parser.new(:rules => ":name or :bust", :tokenize => "a 'not a'", :repeating => true)
         parser.tokenize.should == ["\\s+A(\\s|$)","\\s+NOT\\s+A(\\s|$)"]
         parser.tokenize_no_spaces.should == ["A","NOT\\s+A"]
       end
    
     
       it "should espace tokens as required" do
         parser = Parser.new(:tokenize => "( ) abc |")
         parser.tokenize.should == ['\(','\)','\s+ABC(\s|$)','\|']
         parser.tokenize_regex.should == '\(|\)|\s+ABC(\s|$)|\|'
         parser.tokenize_no_spaces.should == ['\(','\)','ABC','\|']
         parser.tokenize_regex_no_spaces.should == '\(|\)|ABC|\|'
       end
     
     end
      
      
     describe "#rules" do
     
       it "should end on constant if tokens present" do
         Parser.new(:rules => ":name", :tokenize => ")").rules.should == [ { :rule => :name, :stop => :end } ]
       end
    
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
         Parser.new(:rules => "blah").constants.should == ["\\s+BLAH(\\s|$)"]
       end
     
       it "should deal with multiple constants" do
         Parser.new(:rules => ":name = :blah and :moreblah").constants.should == ["=","\\s+AND(\\s|$)"]
       end
     
     end
     
     describe "#constants_no_spaces" do
       
       it "should be empty if only variables" do
         Parser.new(:rules => ":name :blah").constants_no_spaces.should == [ ]
       end
     
       it "should track all constants" do
         Parser.new(:rules => ":name : :date").constants_no_spaces.should == [ ":" ]
       end
     
       it "should upper case constants" do
         Parser.new(:rules => "blah").constants_no_spaces.should == ["BLAH"]
       end
     
       it "should deal with multiple constants" do
         Parser.new(:rules => ":name = :blah and :moreblah").constants_no_spaces.should == ["=","AND"]
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
         @parser.parse_word(nil,nil).should == [nil,nil]
         @parser.parse_word("",nil).should == [nil,nil]
       end
     
       it "should look for global tokens" do
        parser = Parser.new(:tokenize => "xx")
        parser.parse_word("blah xx",:end).should == ["blah","xx"]
        parser.parse_word("blah xx stop","stop").should == ["blah","xx stop"]
      end
    
      it "should handle :end" do
        @parser.parse_word("blah",:end).should == ["blah",nil]
        @parser.parse_word("more blah blah blah",:end).should == ["more blah blah blah",nil]
      end
    
      it "should handle :space" do
        @parser.parse_word("more blah blah blah",:space).should == ["more","blah blah blah"]
        @parser.parse_word("who dat",:space).should == ["who","dat"]
      end
    
      it "should handle :space when no more spaces" do
        @parser.parse_word("blah",:space).should == ["blah",nil]
      end
    
      it "should strip front space" do
        @parser.parse_word(" blah ",:space).should == ["blah",nil]
        @parser.parse_word(" more blah blah blah ",:space).should == ["more","blah blah blah"]
        @parser.parse_word(" who dat ",:space).should == ["who","dat"]
      end
    
      it "should on constant" do
        @parser.parse_word(" blah stuff = more blah stuff ","=").should == ["blah stuff","= more blah stuff"]
      end
    
      it "should be case insensitive" do
        @parser.parse_word(" blah stuff on more blah stuff ","on").should == ["blah stuff","on more blah stuff"]
        @parser.parse_word(" blah stuff ON more blah stuff ","on").should == ["blah stuff","ON more blah stuff"]
        @parser.parse_word(" blah stuff on more blah stuff ","ON").should == ["blah stuff","on more blah stuff"]
      end
    
      it "should grab whole string if not constant not present" do
        @parser.parse_word(" blah ","x").should == ["blah", nil]
      end
    
      it "should be able to explicitly set if you want an exact match or not" do
        @parser.parse_word(" aa bbb ","x",false).should == ["aa bbb", nil]
        @parser.parse_word(" aa bbb ","x",true).should == [nil, "aa bbb"]
    
        @parser.parse_word(" aa bbb ","bbb",false).should == ["aa", "bbb"]
        @parser.parse_word(" aa bbb ","bbb",true).should == ["aa", "bbb"]
      end
      
      it "should remove tokens from the beginning (if non alphabet)" do
        parser = Appstats::Parser.new(:tokenize => "xx1 yy1 zz1")
        parser.parse_word(" xx1 yy1 zz1 zz1aa bbb ",:space).should == ["aa", "bbb"]
        parser.raw_results.should == [ "xx1", "yy1", "zz1", "zz1" ]
      end

      it "should not remove tokens from the beginning (if alphabet)" do
        parser = Appstats::Parser.new(:tokenize => "xx yy zz")
        parser.parse_word(" xx yy zz zzaa bbb ",:space).should == ["zzaa", "bbb"]
        parser.raw_results.should == [ "xx", "yy", "zz" ]
      end

    
      it "should remove tokens from the end (:space)" do
        parser = Parser.new(:tokenize => "xx yy zz")
        parser.parse_word("  aa xx y z bbb ",:space).should == ["aa", "xx y z bbb"]
        parser.raw_results.should == [ ]
      end
    
      it "should remove tokens from the end (:end)" do
        parser = Parser.new(:tokenize => "xx yy zz")
        parser.parse_word("  aa xx y z bbb ",:end).should == ["aa", "xx y z bbb"]
        parser.raw_results.should == [ ]
      end
    
      it "should remove tokens from the end (constant)" do
        parser = Parser.new(:tokenize => "xx yy zz")
        parser.parse_word("  aa xx y on z bbb ","on").should == ["aa", "xx y on z bbb"]
        parser.raw_results.should == [ ]
      end
    
      it "should handle constants" do
        parser = Parser.new(:rules => ":operation :action :date on :server where :contexts")
        parser.parse_word("today on my.local where stuff","on",true).should == ["today","on my.local where stuff"]  
      end
    
    end
    
    describe "#merge_regex_filter" do
      
      it "should handle nil" do
        Parser.merge_regex_filter([nil,nil]).should == ""
        Parser.merge_regex_filter(['','']).should == ""
      end
    
      it "should handle nil on one side" do
        Parser.merge_regex_filter(['\s',nil]).should == '(\s)'
        Parser.merge_regex_filter([nil,'\s']).should == '(\s)'
        Parser.merge_regex_filter(['\s','']).should == '(\s)'
        Parser.merge_regex_filter(['','\s']).should == '(\s)'
      end
    
      it "should handle both sides" do
        Parser.merge_regex_filter(['\s','a|b']).should == '(\s|a|b)'
      end
    
      it "should handle three inputs" do
        Parser.merge_regex_filter(['\s','a|b','dd']).should == '(\s|a|b|dd)'
        Parser.merge_regex_filter(['\s','',nil]).should == '(\s)'
      end
      
      
    end
     
    describe "#alpha?" do
      
      it "should be false for nil" do
        Parser.alpha?(nil).should == false
      end
    
      it "should be false for empty string" do
        Parser.alpha?('').should == false
      end
    
      it "should be false for non alpha string" do
        Parser.alpha?('1abc').should == false
        Parser.alpha?('abc2').should == false
        Parser.alpha?('abc2def').should == false
      end
    
      it "should be true for  alpha string" do
        Parser.alpha?('a').should == true
        Parser.alpha?('abc').should == true
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
      
      describe "non repeating" do
      
        it "passes on a simple rule" do
          parser = Parser.new(:rules => ":name")
          parser.parse("blah").should == true
          parser.raw_results.should == [ {:name => "blah"} ]
        end
          
        it "passes on several rules" do
          parser = Parser.new(:rules => ":one :two :three")
          parser.parse("a  bbb cc").should == true
          parser.results.should == {:one => "a",  :two => "bbb", :three => "cc" }
        end
        
        it "passes on combination of constants and rules" do
          parser = Parser.new(:rules => ":operation :action :date on :server where :contexts")
          parser.parse("# logins today on my.local where stuff").should == true
          parser.results.should == {:operation => "#",  :action => "logins",  :date => "today" ,  :server => "my.local",  :contexts => "stuff" }
        end
    
        it "passes on combination of constants and rules" do
          parser = Parser.new(:rules => ":operation :action :date on :server where :contexts")
          parser.parse("# logins where stuff").should == true
          parser.results.should == {:operation => "#",  :action => "logins",  :date => nil ,  :server => nil, :contexts => "stuff" }
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
          parser.results.should == {:one => "1 one",  :two => "222",  :three => nil }
        end
        
      end
    
      describe "repeating" do
        
        it "should tokenize single repeating entities" do
          parser = Appstats::Parser.new(:rules => ":context", :repeating => true, :tokenize => "and or || && = <= >= <> !=")
          parser.parse("a = b").should == true
          parser.raw_results.should == [ { :context => "a"}, "=", { :context => "b"} ]
        end
    
      end
    
      it "should tokenize tokens" do
        parser = Appstats::Parser.new(:rules => ":context_key = :context_value", :tokenize => "( )")
        parser.parse("( ( a = b ) )").should == true
        parser.raw_results.should == [ "(", "(", { :context_key => "a"}, "=", { :context_value => "b"}, ")", ")" ]
      end
    
      it "should handle tokens with spaces" do
        parser = Parser.new(:rules => ":context", :repeating => true, :tokenize => "like 'not like'")
        parser.parse("a  not like  b").should == true
        parser.raw_results.should == [ { :context => "a"}, "not like", { :context => "b"} ]
      end
    
      it "should handle tokens with many spaces" do
        parser = Parser.new(:rules => ":context", :repeating => true, :tokenize => "like 'not like'")
        parser.parse("a  not   like  b").should == true
        parser.raw_results.should == [ { :context => "a"}, "not   like", { :context => "b"} ]
      end
    
    
      it "should tokenize letters only if spaces between them" do
        parser = Appstats::Parser.new(:rules => ":one :two", :tokenize => "( aa a1 )")
        parser.parse("(blaa aa   a1   bla1)").should == true
        parser.raw_results.should == [ "(", { :one => "blaa"}, "aa", "a1", { :two => "bla1"}, ")" ]
      end
    
      it "should handle alpha constants as requiring spaces" do
        parser = Appstats::Parser.new(:rules => ":one group :two")
        parser.parse("group_by group aha")
        parser.raw_results.should == [  { :one => "group_by"}, "group", { :two => "aha"} ]
      end
    
    
      describe "real examples" do
        
        it "should find host" do
          parser = Appstats::Parser.new(:rules => ":operation :action :date on :host where :contexts")
          parser.parse("# logins between 2010-01-15 and 2010-01-31 on your.localnet").should == true
          parser.results.should == {:operation => "#", :action => "logins", :date => "between 2010-01-15 and 2010-01-31", :host => "your.localnet", :contexts => nil }
        end
        
        it "should handle last week" do
    
          parser = Appstats::Parser.new(:rules => ":operation :action :date on :host where :contexts")
          parser.parse("# logins last week where service_provider = Cox Communications").should == true
          parser.results.should == {:operation => "#", :action => "logins", :date => "last week", :host => nil, :contexts => "service_provider = Cox Communications" }
    
        end
        
        it "should handle lots of brackets" do
          parser = Appstats::Parser.new(:rules => ":context", :repeating => true, :tokenize => "and or || && = <= >= <> != ( ) like")
          parser.parse("(a=b and c=4) or (aaa=5)").should == true
          parser.raw_results.should == ["(", {:context=>"a"}, "=", {:context=>"b"}, "and", {:context=>"c"}, "=", {:context=>"4"}, ")", "or", "(", {:context=>"aaa"}, "=", {:context=>"5"}, ")"]
        end
        
        it "should not get stuck with on within a word" do
          parser = Appstats::Parser.new(:rules => ":operation :action :date on :host where :contexts")
          parser.parse("# buyer-address-lookup last month").should == true
          parser.raw_results.should == [{:operation=>"#"}, {:action=>"buyer-address-lookup"}, {:host=>nil}, {:contexts=>nil}, {:date=>"last month"}]
        end
       
        it "should handle group_by" do
          parser = Appstats::Parser.new(:rules => ":operation :action :date on :host where :contexts group by :group_by")
          parser.parse("# appstats_queries where action = abc AND contexts = 'def' || group_by like 'hik'").should == true
          parser.results.should == {:operation => "#", :action => "appstats_queries", :date => nil, :host => nil, :group_by => nil, :contexts => "action = abc AND contexts = 'def' || group_by like 'hik'" }
        end
       
        it "should handle 'in' in context data" do
          parser = Appstats::Parser.new(:rules => ":context", :repeating => true, :tokenize => "( ) and or || && = <= >= <> < > != like 'not like' in 'not in'")          
          parser.parse("invisible_member_names = Time Warner Cable")
          parser.raw_results.should == [ {:context => "invisible_member_names"}, "=", {:context=>"Time Warner Cable"} ]
        end
        
      end
      
    end
    
  end
end