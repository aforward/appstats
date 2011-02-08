require 'spec_helper'

module Appstats
  describe Query do

    describe "#initialize" do
      
      before(:each) do
        @query = Appstats::Query.new
      end
      
      it "should set input to nil" do
        @query.input.should == nil
      end
      
      it "should allow input on constructor" do
        query = Appstats::Query.new(:input => "# logins")
        query.input.should == "# logins"
      end
      
    end
    
    describe "#to_sql" do
      
      before(:all) do
        Appstats::Action.delete_all
        Appstats::Action.create(:name => "login", :plural_name => "logins")
      end
      
      it "should return understand nil" do
        expected_sql = "select count(*) from appstats_entries"
        Appstats::Query.new(:input => nil).to_sql.should == expected_sql
        Appstats::Query.new(:input => "").to_sql.should == expected_sql
        Appstats::Query.new.to_sql.should == expected_sql
      end
      
      describe "actions" do
        
        it "should understand both singular and plural names" do
          expected_sql = "select count(*) from appstats_entries where action = 'login'"
          Appstats::Query.new(:input => "# logins").to_sql.should == expected_sql
          Appstats::Query.new(:input => "# login").to_sql.should == expected_sql
        end
        
        it "should use 'itself' if action not found" do
          expected_sql = "select count(*) from appstats_entries where action = 'garblygook'"
          Appstats::Query.new(:input => "# garblygook").to_sql.should == expected_sql
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