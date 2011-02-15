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
          expected_sql = "select count(*) from appstats_entries where action = 'login' and exists (select * from appstats_log_collectors where appstats_entries.appstats_log_collector_id = appstats_log_collectors.id and host = 'my.localnet')"
          Appstats::Query.new(:query => "# logins on my.localnet").query_to_sql.should == expected_sql
        end
    
      end
      
      describe "date range and server_name" do
        it "should understand  dates and 'on'" do
          expected_sql = "select count(*) from appstats_entries where action = 'login' and (occurred_at >= '2010-01-15 00:00:00' and occurred_at <= '2010-01-31 23:59:59') and exists (select * from appstats_log_collectors where appstats_entries.appstats_log_collector_id = appstats_log_collectors.id and host = 'your.localnet')"
          Appstats::Query.new(:query => "# logins between 2010-01-15 and 2010-01-31 on your.localnet").query_to_sql.should == expected_sql
        end
      end
    
      describe "where clause" do
        
        it "should understand no quotes" do
          pending "Refactored query to use a homebrew 'parser'"
          # expected_sql = "select count(*) from appstats_entries where action = 'login' and EXISTS(select * from appstats_contexts where appstats_contexts.appstats_entry_id=appstats_entries.id and context_key='user' and context_value='aforward' )"
          # Appstats::Query.new(:query => "# logins where user=aforward").query_to_sql.should == expected_sql
        end
        
        
      end
      
      
      
    end
    
    describe "#host_filter_to_sql" do
    
      it "should translate blah into EXISTS query" do
        expected = "EXISTS (select * from appstats_log_collectors where appstats_entries.appstats_log_collector_id = id and host = 'a' )"
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
    
    describe "#context_filter_to_sql" do
      
      it "should translate a = b into EXISTS query" do
        expected = "EXISTS (select * from appstats_contexts where appstats_entries.id = appstats_contexts.appstats_entry_id and context_key='a' and context_value='b' )"
        Appstats::Query.context_filter_to_sql("a = b").should == expected
      end
    
      it "should ignore single quotes" do
        Appstats::Query.context_filter_to_sql("'a' = b").should == "1=1"
      end
      
      it "should do simple 1 = 1 if invalid" do
        Appstats::Query.context_filter_to_sql("blah").should == "1=1"
        Appstats::Query.context_filter_to_sql("").should == "1=1"
        Appstats::Query.context_filter_to_sql(nil).should == "1=1"
      end
      
    end
  end
end