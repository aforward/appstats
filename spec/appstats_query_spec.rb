require 'spec_helper'

module Appstats

  describe AppstatsQuery do

    before(:each) do
      Time.stub!(:now).and_return(Time.parse('2010-09-21 23:15:20'))
      @appstats_query = AppstatsQuery.new
    end

    describe "#available_action?" do
  
      it "should be false for nil" do
        AppstatsQuery.available_action?(nil).should == false
        AppstatsQuery.available_action?("").should == false
      end
  
      it "should be false for blah" do
        AppstatsQuery.available_action?("blah").should == false
      end
  
      it "should be true for appstats_queries" do
        AppstatsQuery.available_action?("appstats_queries").should == true
        AppstatsQuery.available_action?("Appstats_queries").should == true
        AppstatsQuery.available_action?("appstats_query").should == true
      end
  
    end
  
    describe "#query_to_sql" do
  
      it "should be nil if no query" do
        @appstats_query.query_to_sql.should == "select 0 as num"
      end
  
      it "should be based on query" do
        @appstats_query.query = Appstats::Query.new(:query => "# appstats_queries")
        @appstats_query.query_to_sql.should == @appstats_query.query.query_to_sql
      end
  
    end
  
    describe "#group_query_to_sql" do
  
      it "should be nil if no query" do
        @appstats_query.group_query_to_sql.should == nil
      end
  
      it "should be based on query" do
        @appstats_query.query = Appstats::Query.new(:query => "# appstats_queries")
        @appstats_query.group_query_to_sql.should == @appstats_query.query.group_query_to_sql
      end
  
    end
  
    describe "#process_query" do
  
      it "should support nil query" do
        @appstats_query.process_query
        @appstats_query.query_to_sql.should == "select 0 as num"
        @appstats_query.group_query_to_sql.should == nil
      end
  
      it "should be case insensitive on action" do
        @appstats_query.query = Appstats::Query.new(:query => "# Appstats_Queries", :query_type => "Appstats::AppstatsQuery")
        @appstats_query.process_query
        @appstats_query.query_to_sql.should == "select COUNT(*) as num from appstats_results"
        
        @appstats_query.query = Appstats::Query.new(:query => "# aPpstats_Queries", :query_type => "Appstats::AppstatsQuery")
        @appstats_query.process_query
        @appstats_query.query_to_sql.should == "select COUNT(*) as num from appstats_results"
      end
        
      it "should support singular names" do
        @appstats_query.query = Appstats::Query.new(:query => "# appstats_query", :query_type => "Appstats::AppstatsQuery")
        @appstats_query.process_query
        @appstats_query.query_to_sql.should == "select COUNT(*) as num from appstats_results"
      end
        
      it "should handle nil actions" do
        @appstats_query.query = Appstats::Query.new(:query => "", :query_type => "Appstats::AppstatsQuery")
        @appstats_query.process_query
        @appstats_query.query_to_sql.should == "select 0 as num"
      end
        
      it "should call query.run" do
        @appstats_query.query = Appstats::Query.new(:query => "# appstats_queries", :query_type => "Appstats::AppstatsQuery")
        @appstats_query.query.stub!(:run).and_return("call-worked")
        @appstats_query.run.should == "call-worked"
      end
        
      it "should actually execute code properly" do
        Result.create
        @appstats_query.query = Appstats::Query.new(:query => "# appstats_queries", :query_type => "Appstats::AppstatsQuery")
        @appstats_query.run.count.should > 0
      end
        
      describe "# appstats_queries" do
        
        it "should support #appstats_queries" do
          @appstats_query.query = Appstats::Query.new(:query => "# appstats_queries", :query_type => "Appstats::AppstatsQuery")
          @appstats_query.process_query
          @appstats_query.query_to_sql.should == "select COUNT(*) as num from appstats_results"
          @appstats_query.group_query_to_sql.should == nil
        end

        it "should support where clause for action, contexts, group_by" do
          @appstats_query.query = Appstats::Query.new(:query => "# appstats_queries where action = abc AND contexts = 'def' || group_by like 'hik'", :query_type => "Appstats::AppstatsQuery")
          @appstats_query.process_query
          @appstats_query.query_to_sql.should == "select COUNT(*) as num from appstats_results where action = 'abc' AND contexts = 'def' or group_by like 'hik'"
          @appstats_query.group_query_to_sql.should == nil
        end
        
        it "should support group by action, contexts, group_by" do
          @appstats_query.query = Appstats::Query.new(:query => "# appstats_queries group by action, contexts, group_by", :query_type => "Appstats::AppstatsQuery")
          @appstats_query.process_query
          @appstats_query.query_to_sql.should == "select COUNT(*) as num from appstats_results"
          @appstats_query.group_query_to_sql.should == "select 'action,contexts,group_by' as context_key_filter, concat(ifnull(action,'--'),',',ifnull(contexts,'--'),',',ifnull(group_by,'--')) as context_value_filter, COUNT(*) as num from appstats_results group by context_value_filter"
        end
        
      #   it "should support group by media,network" do
      #     @appstats_query.query = Appstats::Query.new(:query => "# buildings group by media, network", :query_type => "Appstats::AppstatsQuery")        
      #     @appstats_query.process_query
      #     @appstats_query.query_to_sql.should == "select COUNT(DISTINCT operator_accesses.id) as num from operator_accesses left join physical_addresses on physical_addresses.id = operator_accesses.physical_address_id left join operator_networks on operator_networks.id = operator_accesses.operator_network_id left join service_providers on service_providers.id = operator_networks.service_provider_id"
      #     @appstats_query.group_query_to_sql.should == "select 'media,network' as context_key_filter, concat(media_types.name,',',operator_networks.name) as context_value_filter, COUNT(*) as num from operator_accesses left join physical_addresses on physical_addresses.id = operator_accesses.physical_address_id left join operator_networks on operator_networks.id = operator_accesses.operator_network_id left join service_providers on service_providers.id = operator_networks.service_provider_id group by context_value_filter"
      #   end
        
      end
      
      describe "# booms" do

        it "should return nil results (catch the exception)" do
          @appstats_query.query = Appstats::Query.new(:query => "# booms", :query_type => "Appstats::AppstatsQuery")
          @appstats_query.process_query
          @appstats_query.query_to_sql.should == "invalid sql"
          @appstats_query.group_query_to_sql.should == nil
          @appstats_query.run.count.should == nil
        end
        
      end
      
    end
  
    describe "#db_connection" do
  
      it "should use the extract_env" do
        @appstats_query.query = Appstats::Query.new(:query => "# blahs on blah")
        @appstats_query.db_connection.should == Appstats.connection
      end
  
    end

  end

end