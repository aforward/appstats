require 'spec_helper'

module Appstats
  describe Query do

    describe "#initialize" do
      
      before(:each) do
        @query = Appstats::Query.new
      end
      
      it "should set input to nil" do
        @query.query.should == nil
      end
      
      it "should allow query on constructor" do
        query = Appstats::Query.new(:query => "# logins")
        query.query.should == "# logins"
      end
      
    end
    
    describe "#input" do
    
      it "should set the inputs to nil if input invalid" do
        query = Appstats::Query.new(:query => "# myblahs today on xyz.localnet")
        query.query = nil
        query.action.should == nil
        query.host.should == nil
        query.date_range.should == DateRange.new
        
      end
    
      it "should set the action and host" do
        query = Appstats::Query.new(:query => "# myblahs today on xyz.localnet")
        query.action.should == "myblahs"
        query.host.should == "xyz.localnet"
        query.date_range.should == DateRange.parse("today")
      end
    
      it "should understand the short hand 'on' instead of 'on server'" do
        query = Appstats::Query.new(:query => "# myblahs on xyz.localnet")
        query.action.should == "myblahs"
        query.host.should == "xyz.localnet"
        query.date_range.should == DateRange.new
      end
    
      it "should understand the old 'on server' instead of new 'on'" do
        query = Appstats::Query.new(:query => "# myblahs on server xyz.localnet")
        query.action.should == "myblahs"
        query.host.should == "xyz.localnet"
        query.date_range.should == DateRange.new
      end
    
    end
    
    describe "#run" do
      
      before(:each) do
        Appstats::Entry.delete_all
      end
      
      it "should return 0 if no results" do
        query = Appstats::Query.new(:query => "# blahs")
        result = query.run
        result.new_record?.should == false
        result.should == Appstats::Result.new(:result_type => :on_demand, :query => "# blahs", :query_as_sql => query.query_to_sql, :count => 0, :action => "blahs")
      end
    
      it "should track the count if available" do
        Appstats::Entry.create(:action => "myblahs")
        query = Appstats::Query.new(:query => "# myblahs")
        query.run.count.should == 1
        Appstats::Entry.create(:action => "myblahs")
        query.run.count.should == 2
      end
      
      it "should perform the action search" do
        Appstats::Entry.create_from_logger("myblahs", :one => "11", :two => "222")
        Appstats::Entry.create_from_logger("myblahs", :one => "111", :two => "22")

        query = Appstats::Query.new(:query => "# myblahs where one=11")
        result = query.run
        result.count.should == 1

        query = Appstats::Query.new(:query => "# myblahs where one=anything")
        query.run.count.should == 0

        query = Appstats::Query.new(:query => "# myblahs where one=11 && two=22")
        query.run.count.should == 0

        query = Appstats::Query.new(:query => "# myblahs where one=11 || two=22")
        query.run.count.should == 2
      end
    
    end
    
    
    describe "#query_to_sql" do
      
      before(:all) do
        Appstats::Action.delete_all
        Appstats::Action.create(:name => "login", :plural_name => "logins")
      end
      
      it "should return understand nil" do
        expected_sql = "select 0 from appstats_entries LIMIT 1"
        Appstats::Query.new(:query => nil).query_to_sql.should == expected_sql
        Appstats::Query.new(:query => "").query_to_sql.should == expected_sql
        Appstats::Query.new.query_to_sql.should == expected_sql
      end
      
      describe "actions" do
        
        it "should understand both singular and plural names" do
          expected_sql = "select count(*) from appstats_entries where action = 'login'"
          Appstats::Query.new(:query => "# logins").query_to_sql.should == expected_sql
          Appstats::Query.new(:query => "# login").query_to_sql.should == expected_sql
        end
        
        it "should use 'itself' if action not found" do
          expected_sql = "select count(*) from appstats_entries where action = 'garblygook'"
          Appstats::Query.new(:query => "# garblygook").query_to_sql.should == expected_sql
        end
        
      end
      
      describe "date ranges" do
        it "should understand since dates" do
          expected_sql = "select count(*) from appstats_entries where action = 'login' and occurred_at >= '2010-01-15 00:00:00'"
          Appstats::Query.new(:query => "# logins since 2010-01-15").query_to_sql.should == expected_sql
        end
      end
    
      describe "server_name" do
        
        it "should on_name" do
          expected_sql = "select count(*) from appstats_entries where action = 'login' and EXISTS (select * from appstats_log_collectors where appstats_entries.appstats_log_collector_id = appstats_log_collectors.id and host = 'my.localnet' )"
          Appstats::Query.new(:query => "# logins on my.localnet").query_to_sql.should == expected_sql
        end
    
      end
      
      describe "date range and server_name" do
        it "should understand  dates and 'on'" do
          expected_sql = "select count(*) from appstats_entries where action = 'login' and (occurred_at >= '2010-01-15 00:00:00' and occurred_at <= '2010-01-31 23:59:59') and EXISTS (select * from appstats_log_collectors where appstats_entries.appstats_log_collector_id = appstats_log_collectors.id and host = 'your.localnet' )"
          Appstats::Query.new(:query => "# logins between 2010-01-15 and 2010-01-31 on your.localnet").query_to_sql.should == expected_sql
        end
      end
    
     describe "where clause" do
       
       it "should understand no quotes" do
         expected_sql = "select count(*) from appstats_entries where action = 'login' and EXISTS (select * from appstats_contexts where appstats_entries.id = appstats_contexts.appstats_entry_id and ( (context_key = 'user' and context_value = 'aforward')))"
         Appstats::Query.new(:query => "# logins where user = aforward").query_to_sql.should == expected_sql
       end
     end
    end
    
    describe "#host_filter_to_sql" do
    
      it "should translate blah into EXISTS query" do
        expected = "EXISTS (select * from appstats_log_collectors where appstats_entries.appstats_log_collector_id = appstats_log_collectors.id and host = 'a' )"
        Appstats::Query.host_filter_to_sql("a").should == expected
        Appstats::Query.host_filter_to_sql(" a  ").should == expected
      end
    
      it "should ignore single quotes and spaces" do
        Appstats::Query.host_filter_to_sql("bl'ah").should == "1=1"
        Appstats::Query.host_filter_to_sql("bl ah").should == "1=1"
      end
      
      it "should do simple 1=1 if invalid" do
        Appstats::Query.host_filter_to_sql("").should == "1=1"
        Appstats::Query.host_filter_to_sql(nil).should == "1=1"
      end
      
    end
    
    describe "#contexts_filter_to_sql" do
      
      before(:each) do
        @template = "EXISTS (select * from appstats_contexts where appstats_entries.id = appstats_contexts.appstats_entry_id and ("
      end
      
      it "should translate a = b into EXISTS query" do
        Appstats::Query.contexts_filter_to_sql("a=b").should == "#{@template} (context_key = 'a' and context_value = 'b')))"
        Appstats::Query.contexts_filter_to_sql(" a =  b ").should == "#{@template} (context_key = 'a' and context_value = 'b')))"
      end
          
      it "should ignore single quotes" do
        Appstats::Query.contexts_filter_to_sql("'aaa'='bbbb'").should == "#{@template} (context_key = 'aaa' and context_value = 'bbbb')))"
        Appstats::Query.contexts_filter_to_sql(" 'aaa' = 'bbbb'  ").should == "#{@template} (context_key = 'aaa' and context_value = 'bbbb')))"
      end
      
      it "should allow for searching for all entries of a certain context" do
        Appstats::Query.contexts_filter_to_sql("aaa").should == "#{@template} (context_key = 'aaa')))"
      end
      
      it "should allow for searching for several entries of a certain context" do
        Appstats::Query.contexts_filter_to_sql("aaa || bbb").should == "#{@template} (context_key = 'aaa') or (context_key = 'bbb')))"
      end

      it "should allow complex queries" do
        Appstats::Query.contexts_filter_to_sql("user='andrew' || user='aforward'").should == "#{@template} (context_key = 'user' and context_value = 'andrew') or (context_key = 'user' and context_value = 'aforward')))"
      end

      it "should support or" do
        Appstats::Query.contexts_filter_to_sql("user='andrew' or user='aforward'").should == "#{@template} (context_key = 'user' and context_value = 'andrew') or (context_key = 'user' and context_value = 'aforward')))"
      end

      it "should support like" do
        Appstats::Query.contexts_filter_to_sql("user like '%andrew%'").should == "#{@template} (context_key = 'user' and context_value like '%andrew%')))"
      end

      it "should support and" do
        Appstats::Query.contexts_filter_to_sql("user='andrew' and user='aforward'").should == "#{@template} (context_key = 'user' and context_value = 'andrew') and (context_key = 'user' and context_value = 'aforward')))"
      end

      
      it "should do simple 1 = 1 if invalid" do
        Appstats::Query.contexts_filter_to_sql("").should == "1=1"
        Appstats::Query.contexts_filter_to_sql(nil).should == "1=1"
      end
      
    end
    
    describe "#sqlize" do
      
      it "should handle nil" do
        Appstats::Query.sqlize(nil).should == nil
        Appstats::Query.sqlize('').should == ''  
      end
      
      it "should understand &&" do
        Appstats::Query.sqlize("&&").should == "and"
      end

      it "should understand ||" do
        Appstats::Query.sqlize("||").should == "or"
      end

      it "should understand !=" do
        Appstats::Query.sqlize("!=").should == "<>"
      end
      
      it "should set everything else as-is" do
        Appstats::Query.sqlize("blah").should == "blah"
      end
      
    end
    
    describe "#sqlclean" do
      
      it "should handle nil" do
        Appstats::Query.sqlclean(nil).should == nil
        Appstats::Query.sqlclean('').should == ''  
      end
      
      it "should remove exterior quotes" do
        Appstats::Query.sqlclean("'a'").should == "a"
        Appstats::Query.sqlclean("'bbb'").should == "bbb"
        Appstats::Query.sqlclean('"a"').should == "a"
        Appstats::Query.sqlclean('"bbb"').should == "bbb"
      end
      
      it "should handle normal text" do
        Appstats::Query.sqlclean('abc').should == 'abc'
      end

      it "should handle slashes" do
        Appstats::Query.sqlclean('a\b').should == 'a\\\\b'
      end

      it "should handle single quotes" do
        Appstats::Query.sqlclean("a'b").should == "a''b"
      end      
      
    end
    
    describe "#comparators" do
    
      it "should be a list " do
        Appstats::Query.comparators.should == ["=","!=","<>",">","<",">=","<=","like"]
      end
    
    end
    
    describe "#comparator?" do

      it "should not consider nil" do
        Appstats::Query.comparator?(nil).should == false
        Appstats::Query.comparator?("").should == false
      end

      
      it "should not consider &&" do
        Appstats::Query.comparator?("&&").should == false
      end

      it "should not consider ||" do
        Appstats::Query.comparator?("||").should == false
      end

      it "should not consider and" do
        Appstats::Query.comparator?("and").should == false
      end
      
      it "should not consider or" do
        Appstats::Query.comparator?("or").should == false
      end

      it "should consider =" do
        Appstats::Query.comparator?("=").should == true
      end

      it "should consider !=" do
        Appstats::Query.comparator?("!=").should == true
      end
      
      it "should consider <>" do
        Appstats::Query.comparator?("<>").should == true
      end

      it "should consider >" do
        Appstats::Query.comparator?(">").should == true
      end

      it "should consider <" do
        Appstats::Query.comparator?("<").should == true
      end

      it "should consider >=" do
        Appstats::Query.comparator?(">=").should == true
      end

      it "should consider <=" do
        Appstats::Query.comparator?("<=").should == true
      end
      
      
    end
    
    
    
  end
end