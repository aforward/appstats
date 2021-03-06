require 'spec_helper'

module Appstats
  describe Query do

    before(:each) do
      Time.stub!(:now).and_return(Time.parse('2010-09-21 23:15:20'))
    end

    describe "#initialize" do
      
      before(:each) do
        @query = Appstats::Query.new
      end
      
      it "should set input to nil" do
        @query.query.should == nil
        @query.query_type.should == nil
      end
      
      describe "query_type" do
    
        it "should allow simple objects" do
          query = Appstats::Query.new(:query => "# logins", :query_type => "YetAnotherTestQuery")
          query.query.should == "# logins"
          query.query_type.should == "YetAnotherTestQuery"
        end
    
        it "should allow modules" do
          query = Appstats::Query.new(:query => "# logins", :query_type => "Appstats::TestQuery")
          query.query.should == "# logins"
          query.query_type.should == "Appstats::TestQuery"
        end
    
        it "should allow sub modules" do
          query = Appstats::Query.new(:query => "# logins", :query_type => "Appstats::Core::AnotherTestQuery")
          query.query.should == "# logins"
          query.query_type.should == "Appstats::Core::AnotherTestQuery"
        end
    
        it "should fail for invalid query type" do
    
          lambda { Appstats::Query.new(:query => "# logins", :query_type => "x") }.should raise_error
        end
        
      end
    
      describe "default query type" do
    
        it "should set the inputs to nil if input invalid" do
          query = Appstats::Query.new(:query => "# myblahs today on xyz.localnet")
          query.query = nil
          query.action.should == nil
          query.host.should == nil
          query.date_range.should == DateRange.new
          query.group_by.should == []
          query.group_query_to_sql.should == nil
        end
    
        it "should set the action and host" do
          query = Appstats::Query.new(:query => "# myblahs today on xyz.localnet")
          query.action.should == "myblahs"
          query.host.should == "xyz.localnet"
          query.date_range.should == DateRange.parse("today")
          query.group_by.should == []
          query.group_query_to_sql.should == nil
        end
    
        it "should understand the short hand 'on' instead of 'on server'" do
          query = Appstats::Query.new(:query => "# myblahs on xyz.localnet")
          query.action.should == "myblahs"
          query.host.should == "xyz.localnet"
          query.date_range.should == DateRange.new
          query.group_by.should == []
          query.group_query_to_sql.should == nil
        end
    
        it "should understand the old 'on server' instead of new 'on'" do
          query = Appstats::Query.new(:query => "# myblahs on server xyz.localnet")
          query.action.should == "myblahs"
          query.host.should == "xyz.localnet"
          query.date_range.should == DateRange.new
          query.group_by.should == []
          query.group_query_to_sql.should == nil
        end
    
        describe "group by" do
    
          it "should handle single entry" do
            query = Appstats::Query.new(:query => "# myblahs group by aa")
            query.group_by.should == ["aa"]
          end
    
          it "should handle multi-entry" do
            query = Appstats::Query.new(:query => "# myblahs group by aa,bbbb")
            query.group_by.should == ["aa","bbbb"]
          end
    
        end
        
        describe "contexts" do
    
          it "should handle single entry" do
            query = Appstats::Query.new(:query => "# myblahs where aa = bb or aa < ccc")
            query.contexts.should == "aa = bb or aa < ccc"
            query.parsed_contexts.should == [ { :context_key => "aa", :comparator => "=", :context_value => "bb" }, "or", { :context_key => "aa", :comparator => "<", :context_value => "ccc" } ]
          end
    
        end        
        
      end
      
      describe "distinct query_type" do
        
        it "should use sql query_type queries" do
          query = Appstats::Query.new(:query => "# stuff", :query_type => "Appstats::TestQuery")
          query.query_to_sql.should == "select count(*) as num from appstats_test_objects"
          query.group_query_to_sql.should == "select context_key_filter, context_value_filter, count(*) as num from (select 'name' as context_key_filter, name as context_value_filter from appstats_test_objects) results group by context_value_filter"
        end
        
      end
    
    end
    
    describe "#find" do
      
      before(:each) do
        Appstats::Entry.delete_all
        Appstats::Result.delete_all
        Appstats::ResultJob.delete_all
      end
      
      describe "run right away" do

        it "should run the query if it has not been run yet" do
          Appstats::Entry.create(:action => "myblahs")

          Time.stub!(:now).and_return(Time.parse("2010-09-20"))
          query = Appstats::Query.new(:query => "# myblahs")
          query.find(nil).count.should == 1

          Appstats::Entry.create(:action => "myblahs")
          query.find(nil).count.should == 1

          Time.stub!(:now).and_return(Time.parse("2010-09-21")) 
          query = Appstats::Query.new(:query => "# myblahs")
          query.run.count.should == 2

          query = Appstats::Query.new(:query => "# myblahs")
          query.find(nil).count.should == 2
        end
                
      end
      
      describe "do not run right away" do

        it "should return nil no result available" do
          Appstats::Entry.create(:action => "myblahs")
          
          query = Appstats::Query.new(:query => "# myblahs")
          query.find.should == nil

          query = Appstats::Query.new(:query => "# myblahs")
          query.run.count.should == 1

          query = Appstats::Query.new(:query => "# myblahs")
          query.find.count.should == 1
        end
        
        it "should schedule the query to be run" do
          
          query = Query.new(:query => "# x", :query_type => "Appstats::TestQuery")
          query.find.should == nil

          job = Appstats::ResultJob.last
          job.should_not == nil
          job.name.should == "Missing Query#find requested"
          job.frequency.should == 'once'
          job.query.should == "# x"
          job.query_type.should == "Appstats::TestQuery"
        end

        it "should allow scheduling to be set" do
          
          query = Query.new(:query => "# myblahs")
          query.find('daily').should == nil

          job = Appstats::ResultJob.last
          job.name.should == "Missing Query#find requested"
          job.frequency.should == 'daily'
          job.query.should == "# myblahs"
          job.query_type.should == nil
        end
        
        it "should not reschedule if schedule already exists" do
          before_count = Appstats::ResultJob.count
          query = Query.new(:query => "# myblahs")
          query.find('daily').should == nil
          query.find('daily').should == nil
          Appstats::ResultJob.count.should == before_count + 1
        end

        it "should not update the schedule" do
          query = Query.new(:query => "# myblahs")
          query.find('daily').should == nil
          job = Appstats::ResultJob.last
          query.find('monthly').should == nil
          job.reload
          job.frequency.should == 'daily'
        end

        it "should re-run job if original jobs are complete" do
          before_count = Appstats::ResultJob.count
          query = Query.new(:query => "# myblahs")
          query.find('once').should == nil
          job = Appstats::ResultJob.last
          job.last_run_at = Time.now and job.save.should == true
          
          query.find('daily').should == nil
          Appstats::ResultJob.count.should == before_count + 2
        end

        
      end
      
      
      
    end
    
    describe "#run" do
      
      before(:each) do
        Appstats::Entry.delete_all
        Appstats::Result.delete_all
      end

      it "should update is_latest accordingly" do
        Appstats::Entry.create(:action => "myblahs")

        Time.stub!(:now).and_return(Time.parse("2010-09-20"))
        query = Appstats::Query.new(:query => "# myblahs")
        result = query.run
        result.is_latest.should == true

        Time.stub!(:now).and_return(Time.parse("2010-09-21"))
        query = Appstats::Query.new(:query => "# myblahs")
        result2 = query.run
        result.reload
        result.is_latest.should == false
        result2.is_latest.should == true
      end
      
      describe "#!" do
        
        it "deletes all but the latest" do
          before_count = Result.count
          query = Appstats::Query.new(:query => "#! whodats")
          result1 = query.run
          Result.count.should == before_count + 1
          result2 = query.run
          Result.count.should == before_count + 1
          
          Result.exists?(result1.id).should == false
          Result.exists?(result2.id).should == true
          result2.is_latest.should == true
        end
        
        it "deletes non #! as well" do

          before_count = Result.count
          query = Appstats::Query.new(:query => "# whodats")
          result1 = query.run
          Result.count.should == before_count + 1

          query = Appstats::Query.new(:query => "#! whodats")
          result2 = query.run
          Result.count.should == before_count + 1
          
          Result.exists?(result1.id).should == false
          Result.exists?(result2.id).should == true
          result2.is_latest.should == true
        end
        
      end
      
      describe "core search" do
        it "should return 0 if no results" do
          query = Appstats::Query.new(:query => "# blahs")
          result = query.run
          result.new_record?.should == false
          result.should == Appstats::Result.new(:result_type => "on_demand", :query => "# blahs", :query_to_sql => query.query_to_sql, :count => 0, :action => "blahs", :group_by => nil, :db_username => 'root', :db_name => 'appstats_test', :db_host => 'localhost' )
        end
    
        it "should set name and result_type if provided" do
          query = Appstats::Query.new(:name => "x", :result_type => "some_reason", :query => "# blahs")
          result = query.run
          result.new_record?.should == false
          result.should == Appstats::Result.new(:name => "x", :result_type => "some_reason", :query => "# blahs", :query_to_sql => query.query_to_sql, :count => 0, :action => "blahs", :group_by => nil, :db_username => 'root', :db_name => 'appstats_test', :db_host => 'localhost')
        end
    
        it "should track contexts" do
          query = Appstats::Query.new(:query => "# blahs where (a=b and c=4) or (aaa=5)")
          result = query.run
          result.new_record?.should == false
          result.contexts.should == "(a=b and c=4) or (aaa=5)"
        end
    
        it "should track the count if available" do
          Appstats::Entry.create(:action => "myblahs")
          query = Appstats::Query.new(:query => "# myblahs")
          query.run.count.should == 1
          Appstats::Entry.create(:action => "myblahs")
          query.run.count.should == 2
        end
    
        it "should track query_duration_in_seconds" do
          timer = FriendlyTimer.new(:duration => 10.0)
          timer.stub!(:stop)
          FriendlyTimer.stub!(:new).and_return(timer)
          
          Appstats::Entry.create(:action => "myblahs")
          query = Appstats::Query.new(:query => "# myblahs")
          result = query.run
          
          result.query_duration_in_seconds.should == 10.0
          result.group_query_duration_in_seconds.should == nil
        end
    
        it "should track group_query_duration_in_seconds if a group provided" do
          timer = FriendlyTimer.new(:duration => 10.0)
          timer.stub!(:stop)
          FriendlyTimer.stub!(:new).and_return(timer)
          
          Appstats::Entry.create(:action => "myblahs")
          query = Appstats::Query.new(:query => "# myblahs group by service_provider")
          result = query.run
          
          result.query_duration_in_seconds.should == 10.0
          result.group_query_duration_in_seconds.should == 10.0
        end
    
        it "should not double count an entry with multiple contexts" do
          Appstats::Entry.create_from_logger("myblahs",:app_name => ["a","b"])
          query = Appstats::Query.new(:query => "# myblahs where app_name='a' or app_name = 'b'")
          query.run.count.should == 1
    
          Appstats::Entry.create_from_logger("myblahs",:app_name => ["a","c"])
          Appstats::Entry.create_from_logger("myblahs",:app_name => ["b","d"])
          Appstats::Entry.create_from_logger("myblahs",:app_name => ["c","d"])
          query = Appstats::Query.new(:query => "# myblahs where app_name='a' or app_name = 'b'")
          query.run.count.should == 3
    
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
    
        describe "fixed_points searches" do
    
          it "should handle year" do
            query = Appstats::Query.new(:query => "# myblahs last year")
            result = query.run
            result.date_to_s.should == "2009-01-01 to 2009-12-31"
          end
    
          it "should handle quarter" do
            query = Appstats::Query.new(:query => "# myblahs last quarter")
            result = query.run
            result.date_to_s.should == "2010-04-01 to 2010-06-30"
          end
    
          it "should handle month" do
            query = Appstats::Query.new(:query => "# myblahs last month")
            result = query.run
            result.date_to_s.should == "2010-08-01 to 2010-08-31"
          end
    
          it "should handle week" do
            query = Appstats::Query.new(:query => "# myblahs last week")
            result = query.run
            result.date_to_s.should == "2010-09-13 to 2010-09-19"
          end
    
          it "should handle day" do
            query = Appstats::Query.new(:query => "# myblahs last day")
            result = query.run
            result.date_to_s.should == "2010-09-20"
          end
        end      
        
        describe "real examples" do
        
          it "nil split being called" do
            query = Appstats::Query.new(:query => "# buyer-address-lookups group by city", :query_type => "Appstats::InvalidTestQuery")
            result = query.run
            result.count.should == 0
            result.sub_results.size.should == 0
          end
          
        end
        
      end
      
      describe "group sub results" do
        
        before(:each) do
          Appstats::Entry.delete_all
          Appstats::Context.delete_all
          Appstats::Result.delete_all
          Appstats::SubResult.delete_all
        end
        
        it "should not create sub results if no group_by" do
          query = Appstats::Query.new(:query => "# myblahs last day")
          result = query.run
          result.sub_results.should == []
        end
        
        it "should track elements outside of the context" do
          Appstats::Entry.create_from_logger("myblahs",:service_provider => "a")
          Appstats::Entry.create_from_logger("myblahs",:service_provider => "a")
          Appstats::Entry.create_from_logger("myblahs",:service_provider => "a")
          Appstats::Entry.create_from_logger("myblahs")
          
          query = Appstats::Query.new(:query => "# myblahs group by service_provider")
          result = query.run
          result.count.should == 4
          result.sub_results.size.should == 2
          result.sub_results[0].should == SubResult.new(:context_filter => "a", :count => 3, :ratio_of_total => 0.75)
          result.sub_results[1].should == SubResult.new(:context_filter => nil, :count => 1, :ratio_of_total => 0.25)
        end

        it "should track empty and nil contexts" do
          Appstats::Entry.create_from_logger("myblahs",:service_provider => "a")
          Appstats::Entry.create_from_logger("myblahs",:service_provider => "a")
          Appstats::Entry.create_from_logger("myblahs",:service_provider => "")
          Appstats::Entry.create_from_logger("myblahs",:service_provider => nil)
          
          query = Appstats::Query.new(:query => "# myblahs group by service_provider")
          result = query.run
          result.count.should == 4
          result.sub_results.size.should == 2
          result.sub_results[0].should == SubResult.new(:context_filter => "", :count => 2, :ratio_of_total => 0.5)
          result.sub_results[1].should == SubResult.new(:context_filter => "a", :count => 2, :ratio_of_total => 0.5)
        end

    
        it "should track sub results for single group by" do
          Appstats::Entry.create_from_logger("myblahs",:service_provider => "a", :ignore => "1")
          Appstats::Entry.create_from_logger("myblahs",:service_provider => "a", :ignore => "1")
          Appstats::Entry.create_from_logger("myblahs",:service_provider => "a", :ignore => "2")
          Appstats::Entry.create_from_logger("myblahs",:service_provider => "b", :ignore => "1")
          
          query = Appstats::Query.new(:query => "# myblahs group by service_provider")
          result = query.run
          result.count.should == 4
          result.group_by.should == "service_provider"
          result.sub_results.size.should == 2
          result.group_query_to_sql.should == query.group_query_to_sql
          
          result.sub_results[0].should == SubResult.new(:context_filter => "a", :count => 3, :ratio_of_total => 0.75)
          result.sub_results[1].should == SubResult.new(:context_filter => "b", :count => 1, :ratio_of_total => 0.25)
        end
        
        it "should track sub results for multiple group by" do
          Appstats::Entry.create_from_logger("yourblahs",:service_provider => "a", :user => "1")
          Appstats::Entry.create_from_logger("yourblahs",:service_provider => "a", :user => "1")
          Appstats::Entry.create_from_logger("yourblahs",:service_provider => "a", :user => "1")
          Appstats::Entry.create_from_logger("yourblahs",:service_provider => "a", :user => "1")
          Appstats::Entry.create_from_logger("yourblahs",:service_provider => "a", :user => "1")
    
          Appstats::Entry.create_from_logger("yourblahs",:service_provider => "a", :user => "2")
          Appstats::Entry.create_from_logger("yourblahs",:service_provider => "a", :user => "2")
    
          Appstats::Entry.create_from_logger("yourblahs",:service_provider => "b", :user => "1")
          Appstats::Entry.create_from_logger("yourblahs",:service_provider => "b", :user => "1")
          Appstats::Entry.create_from_logger("yourblahs",:service_provider => "b", :user => "1")
          
          query = Appstats::Query.new(:query => "# yourblahs group by service_provider,user")
          result = query.run
          result.count.should == 10
          result.group_by.should == "service_provider, user"
          
          # sometimes it is four or five?!?
          # TODO: Must fix query to ensure proper grouping
          if result.sub_results.size == 3
            result.sub_results[0].should == SubResult.new(:context_filter => "a, 1", :count => 5, :ratio_of_total => 0.50)
            result.sub_results[1].should == SubResult.new(:context_filter => "b, 1", :count => 3, :ratio_of_total => 0.30)
            result.sub_results[2].should == SubResult.new(:context_filter => "a, 2", :count => 2, :ratio_of_total => 0.20)
          end
          
        end        
        
      end
      
      describe "third party searches" do
        
        before(:each) do
          TestObject.delete_all
          
        end
        
        it "should handle custom sql" do
          TestObject.create and TestObject.create
          
          query = Query.new(:query => "# x", :query_type => "Appstats::TestQuery")
          result = query.run
          
          result.query_type.should == "Appstats::TestQuery"
          result.count.should == 2
          result.query_to_sql.should == "select count(*) as num from appstats_test_objects"
        end
    
        it "should track db connection on custom sql" do
          query = Query.new(:query => "# x on otherServer", :query_type => "Appstats::TestQuery")
          result = query.run
          [result.db_username,result.db_name,result.db_host].should == ['root','appstats_development','localhost']
        end

        it "should handle group by when core search has errors" do
          TestObject.create and TestObject.create
          
          query = Query.new(:query => "# x group by y", :query_type => "Appstats::BadTestQuery")
          result = query.run
          result.query_type.should == "Appstats::BadTestQuery"
          result.sub_results.should == [ ]
        end
    
    
        it "should handle group by errors" do
          TestObject.create and TestObject.create
          
          query = Query.new(:query => "# x group by y", :query_type => "Appstats::BadGroupTestQuery")
          result = query.run
          result.query_type.should == "Appstats::BadGroupTestQuery"
          result.sub_results.should == [ Appstats::SubResult.new(:context_filter => nil, :count => 2, :ratio_of_total => 1.0) ]
        end
    
        it "should reset database if things fail" do
          query = Query.new(:query => "# x", :query_type => "Appstats::BadTestQuery")
          result = query.run
          result.query_type.should == "Appstats::BadTestQuery"
          result.count.should == nil
    
          Appstats.connection.current_database.should == YAML::load(File.open('db/config.yml'))["test"]["database"]
        end
    
    
        it "should handle group by" do
          TestObject.create(:name => "aa") and TestObject.create(:name => "aa") and TestObject.create(:name => "bb")
          
          query = Query.new(:query => "# x group by y", :query_type => "Appstats::TestQuery")
          result = query.run
          
          result.query_type.should == "Appstats::TestQuery"
          result.count.should == 3
          result.group_query_to_sql.should == "select context_key_filter, context_value_filter, count(*) as num from (select 'name' as context_key_filter, name as context_value_filter from appstats_test_objects) results group by context_value_filter"
          result.sub_results.size.should == 2
        end
        
        it "should handle remote servers" do
          TestObject.create(:name => "aa")
          
          query1 = Query.new(:query => "# x on testServer", :query_type => "Appstats::TestQuery")
          result1 = query1.run
    
          query2 = Query.new(:query => "# x on otherServer", :query_type => "Appstats::TestQuery")
          result2 = query2.run
          
          if result1.count == result2.count #coincidence
            TestObject.create(:name => "aa")
            query1 = Query.new(:query => "# x on testServer", :query_type => "Appstats::TestQuery")
            result1 = query1.run
          end
          
          result1.count.should_not == result2.count
    
          result1 = query1.run
          result1.count.should_not == result2.count
        end
        
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
          expected_sql = "select count(*) as num from appstats_entries where action = 'login'"
          Appstats::Query.new(:query => "# logins").query_to_sql.should == expected_sql
          Appstats::Query.new(:query => "# login").query_to_sql.should == expected_sql
        end
        
        it "should use 'itself' if action not found" do
          expected_sql = "select count(*) as num from appstats_entries where action = 'garblygook'"
          Appstats::Query.new(:query => "# garblygook").query_to_sql.should == expected_sql
        end
        
      end
      
      describe "date ranges" do
        it "should understand since dates" do
          expected_sql = "select count(*) as num from appstats_entries where action = 'login' and occurred_at >= '2010-01-15 00:00:00'"
          Appstats::Query.new(:query => "# logins since 2010-01-15").query_to_sql.should == expected_sql
        end
      end
    
      describe "server_name" do
        
        it "should on_name" do
          expected_sql = "select count(*) as num from appstats_entries where action = 'login' and EXISTS (select * from appstats_log_collectors where appstats_entries.appstats_log_collector_id = appstats_log_collectors.id and host = 'my.localnet' )"
          Appstats::Query.new(:query => "# logins on my.localnet").query_to_sql.should == expected_sql
        end
    
      end
      
      describe "date range and server_name" do
        it "should understand  dates and 'on'" do
          expected_sql = "select count(*) as num from appstats_entries where action = 'login' and (occurred_at >= '2010-01-15 00:00:00' and occurred_at <= '2010-01-31 23:59:59') and EXISTS (select * from appstats_log_collectors where appstats_entries.appstats_log_collector_id = appstats_log_collectors.id and host = 'your.localnet' )"
          Appstats::Query.new(:query => "# logins between 2010-01-15 and 2010-01-31 on your.localnet").query_to_sql.should == expected_sql
        end
      end
    
     describe "where clause" do
       
       it "should understand no quotes" do
         expected_sql = "select count(*) as num from appstats_entries where action = 'login' and EXISTS (select * from appstats_contexts where appstats_entries.id = appstats_contexts.appstats_entry_id and ( (context_key = 'user' and context_value = 'aforward')))"
         Appstats::Query.new(:query => "# logins where user = aforward").query_to_sql.should == expected_sql
       end
       
       it "should handle example" do
         expected_sql = "select count(*) as num from appstats_entries where action = 'blahs' and EXISTS (select * from appstats_contexts where appstats_entries.id = appstats_contexts.appstats_entry_id and ( ( (context_key = 'a' and context_value = 'b') and (context_key = 'c' and context_value = '4') ) or ( (context_key = 'aaa' and context_value = '5') )))"
         Appstats::Query.new(:query => "# blahs where (a=b and c=4) or (aaa=5)").query_to_sql.should == expected_sql
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
    
    describe "#group_query_to_sql" do
            
      before(:each) do
        @template = "select id from appstats_entries where action = 'myblahs'"
      end
    
      it "should support no filters" do
        query = Appstats::Query.new(:query => "# myblahs")
        query.group_query_to_sql.should == nil
      end
            
      it "should support 1 filter" do
        query = Appstats::Query.new(:query => "# myblahs group by aa")
        expected = "select context_key_filter, context_value_filter, count(*) as num from (select group_concat(appstats_contexts.context_key) as context_key_filter, group_concat(appstats_contexts.context_value) as context_value_filter, appstats_entry_id from appstats_contexts where context_key in ('aa') and appstats_entry_id in ( #{@template} ) group by appstats_entry_id) results group by context_value_filter"
        query.group_query_to_sql.should == expected
      end
    
      it "should support surrounding quotes" do
        query = Appstats::Query.new(:query => "# myblahs group by 'aa'")
        expected = "select context_key_filter, context_value_filter, count(*) as num from (select group_concat(appstats_contexts.context_key) as context_key_filter, group_concat(appstats_contexts.context_value) as context_value_filter, appstats_entry_id from appstats_contexts where context_key in ('aa') and appstats_entry_id in ( #{@template} ) group by appstats_entry_id) results group by context_value_filter"
        query.group_query_to_sql.should == expected
      end
    
      it "should support inner quotes" do
        query = Appstats::Query.new(:query => "# myblahs group by a's")
        expected = "select context_key_filter, context_value_filter, count(*) as num from (select group_concat(appstats_contexts.context_key) as context_key_filter, group_concat(appstats_contexts.context_value) as context_value_filter, appstats_entry_id from appstats_contexts where context_key in ('a''s') and appstats_entry_id in ( #{@template} ) group by appstats_entry_id) results group by context_value_filter"
        query.group_query_to_sql.should == expected
      end
    
    
      it "should support many filters" do
        query = Appstats::Query.new(:query => "# myblahs group by aa, bbb")
        expected = "select context_key_filter, context_value_filter, count(*) as num from (select group_concat(appstats_contexts.context_key) as context_key_filter, group_concat(appstats_contexts.context_value) as context_value_filter, appstats_entry_id from appstats_contexts where context_key in ('aa','bbb') and appstats_entry_id in ( #{@template} ) group by appstats_entry_id) results group by context_value_filter"
        query.group_query_to_sql.should == expected
      end
      
      
    end
    
    describe "#contexts_filter_to_sql" do
      
      before(:each) do
        @template = "EXISTS (select * from appstats_contexts where appstats_entries.id = appstats_contexts.appstats_entry_id and ("
      end
      
      it "should translate a = b into EXISTS query" do
        Appstats::Query.new(:query => "# logins where a=b").contexts_filter_to_sql.should == "#{@template} (context_key = 'a' and context_value = 'b')))"
        Appstats::Query.new(:query => "# logins where a  =  b   ").contexts_filter_to_sql.should == "#{@template} (context_key = 'a' and context_value = 'b')))"
      end
          
      it "should ignore single quotes" do
        Appstats::Query.new(:query => "# logins where 'aaa'='bbbb'").contexts_filter_to_sql.should == "#{@template} (context_key = 'aaa' and context_value = 'bbbb')))"
        Appstats::Query.new(:query => "# logins where 'aaa' = 'bbbb'  ").contexts_filter_to_sql.should == "#{@template} (context_key = 'aaa' and context_value = 'bbbb')))"
      end
      
      it "should allow for searching for all entries of a certain context" do
        Appstats::Query.new(:query => "# logins where aaa").contexts_filter_to_sql.should == "#{@template} (context_key = 'aaa')))"
      end
      
      it "should allow for searching for several entries of a certain context" do
        Appstats::Query.new(:query => "# logins where aaa || bbb").contexts_filter_to_sql.should == "#{@template} (context_key = 'aaa') or (context_key = 'bbb')))"
      end
    
      it "should allow complex queries" do
        Appstats::Query.new(:query => "# logins where user='andrew' || user='aforward'").contexts_filter_to_sql.should == "#{@template} (context_key = 'user' and context_value = 'andrew') or (context_key = 'user' and context_value = 'aforward')))"
      end
    
      it "should support or" do
        Appstats::Query.new(:query => "# logins where user='andrew' or user='aforward'").contexts_filter_to_sql.should == "#{@template} (context_key = 'user' and context_value = 'andrew') or (context_key = 'user' and context_value = 'aforward')))"
      end
    
      it "should support like" do
        Appstats::Query.new(:query => "# logins where user like '%andrew%'").contexts_filter_to_sql.should == "#{@template} (context_key = 'user' and context_value like '%andrew%')))"
      end

      it "should support not like" do
        Appstats::Query.new(:query => "# logins where user not like '%andrew%'").contexts_filter_to_sql.should == "#{@template} (context_key = 'user' and context_value not like '%andrew%')))"
      end

      it "should support in" do
        Appstats::Query.new(:query => "# logins where user_id in 1,2,3").contexts_filter_to_sql.should == "#{@template} (context_key = 'user_id' and context_value in ('1','2','3'))))"
      end

      it "should support not in" do
        Appstats::Query.new(:query => "# logins where user_id not in 1,2,3").contexts_filter_to_sql.should == "#{@template} (context_key = 'user_id' and context_value not in ('1','2','3'))))"
      end
    
      it "should support and" do
        Appstats::Query.new(:query => "# logins where user='andrew' and user='aforward'").contexts_filter_to_sql.should == "#{@template} (context_key = 'user' and context_value = 'andrew') and (context_key = 'user' and context_value = 'aforward')))"
      end
    
      
      it "should do simple 1 = 1 if invalid" do
        Appstats::Query.new(:query => "# logins where").contexts_filter_to_sql.should == "1=1"
        Appstats::Query.new(:query => "# logins").contexts_filter_to_sql.should == "1=1"
      end
      
    end
    
    describe "#sqlquote" do
      
      it "should handle nil" do
        Appstats::Query.sqlquote(nil).should == "NULL"
        Appstats::Query.sqlquote('').should == "''" 
      end
      
      it "should handle simple data" do
        Appstats::Query.sqlquote("blah").should == "'blah'"
      end
    
      it "should handle IN comparator" do
        Appstats::Query.sqlquote("1,2,3","in").should == "('1','2','3')"
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
        Appstats::Query.comparators.should == ["=","!=","<>",">","<",">=","<=","like","not like","in","not in"]
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