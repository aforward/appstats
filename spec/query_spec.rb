require 'spec_helper'

module Appstats
  describe Query do

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