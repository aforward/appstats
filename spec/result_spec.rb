require 'spec_helper'

module Appstats
  describe Result do

    before(:each) do
      @result = Appstats::Result.new
      Time.stub!(:now).and_return(Time.parse('2010-09-21 23:15:20'))
    end

    describe "#initialize" do
    
      it "should set attributes to nil" do
        @result.name.should == nil
        @result.result_type.should == nil
        @result.query.should == nil
        @result.query_to_sql.should == nil
        @result.count.should == nil
        @result.action.should == nil
        @result.contexts.should == nil
        @result.from_date.should == nil
        @result.to_date.should == nil
        @result.group_by.should == nil
        @result.query_type.should == nil
        @result.db_username.should == nil
        @result.db_name.should == nil
        @result.db_host.should == nil
        @result.is_latest.should == nil
        @result.is_latest?.should == false
        @result.query_duration_in_seconds.should == nil
        @result.group_query_duration_in_seconds.should == nil
      end
    
      it "should set on constructor" do
        result = Appstats::Result.new(:name => 'a', :result_type => 'b', :query => 'c', :query_to_sql => 'd', :count => 10, :action => 'e', :host => 'f', :contexts => 'g', :from_date => Time.parse("2010-01-02"), :to_date => Time.parse("2010-02-03"), :group_by => "a,b", :query_type => 'h', :db_username => 'i', :db_name => 'j', :db_host => 'k', :is_latest => true, :query_duration_in_seconds => 1.2, :group_query_duration_in_seconds => 3.4)
        result.name.should == 'a'
        result.result_type.should == 'b'
        result.query.should == 'c'
        result.query_to_sql.should == 'd'
        result.count.should == 10
        result.action.should == 'e'
        result.host.should == 'f'
        result.contexts.should == 'g'
        result.from_date_to_s.should == '2010-01-02'
        result.to_date_to_s.should == '2010-02-03'
        result.group_by.should == "a,b"
        result.query_type.should == "h"
        result.db_username.should == "i"
        result.db_name.should == "j"
        result.db_host.should == "k"
        result.is_latest?.should == true
        result.is_latest.should == true
        result.query_duration_in_seconds = 1.2
        result.group_query_duration_in_seconds = 3.4
      end
    
    end
    
    describe "#==" do
      
      it "should be equal on all attributes" do
        result = Appstats::Result.new(:name => 'a', :result_type => 'b', :query => 'c', :query_to_sql => 'd', :count => 10, :action => 'e', :host => 'f', :contexts => 'g', :from_date => Time.parse("2010-01-02"), :to_date => Time.parse("2010-02-03"), :group_by => "a,b", :query_type => 'h', :db_username => 'i', :db_name => 'j', :db_host => 'k')
        same_result = Appstats::Result.new(:name => 'a', :result_type => 'b', :query => 'c', :query_to_sql => 'd', :count => 10, :action => 'e', :host => 'f', :contexts => 'g', :from_date => Time.parse("2010-01-02"), :to_date => Time.parse("2010-02-03"), :group_by => "a,b", :query_type => 'h', :db_username => 'i', :db_name => 'j', :db_host => 'k')
        (result == same_result).should == true
      end
      
      it "should ignore query_duration_in_seconds" do
        result = Appstats::Result.new(:query_duration_in_seconds => 1.2)
        result2 = Appstats::Result.new(:query_duration_in_seconds => 3.4)
        result.should == result2
      end

      it "should ignore group_query_duration_in_seconds" do
        result = Appstats::Result.new(:group_query_duration_in_seconds => 1.2)
        result2 = Appstats::Result.new(:group_query_duration_in_seconds => 3.4)
        result.should == result2
      end
      
      it "should be not equal if diferent attributes" do
        result = Appstats::Result.new(:name => 'a', :result_type => 'b', :query => 'c', :query_to_sql => 'd', :count => 10, :action => 'e', :host => 'f', :contexts => 'g', :from_date => Time.parse("2010-01-02"), :to_date => Time.parse("2010-02-03"), :group_by => "a,b", :query_type => 'h', :db_username => 'i', :db_name => 'j', :db_host => 'k')
        
        [:name,:result_type,:query,:query_to_sql,:count,:action,:host,:contexts,:from_date,:to_date,:group_by,:query_type,:db_username,:db_name,:db_host].each do |attr|
          different_result = Appstats::Result.new(:name => 'a', :result_type => 'b', :query => 'c', :query_to_sql => 'd', :count => 10, :action => 'e', :host => 'f', :contexts => 'g', :from_date => Time.parse("2010-01-02"), :to_date => Time.parse("2010-02-03"), :group_by => "a,b", :query_type => 'h', :db_username => 'i', :db_name => 'j', :db_host => 'k')  

          if [:from_date,:to_date].include?(attr)
            different_result.send("#{attr}=",Time.parse("2011-01-02"))
          else
            different_result.send("#{attr}=","XXX")
          end
          
          different_result.should_not == result
        end
      end

    end
    
    describe "#query_duration_to_s" do
      
      it "should be friendly" do
        @result.query_duration_in_seconds = 10
        @result.query_duration_to_s.should == "10 seconds"
      end

      it "should support nil" do
        @result.query_duration_in_seconds = nil
        @result.query_duration_to_s.should == "N/A"
      end
      
    end

    describe "#group_query_duration_to_s" do
      
      it "should be friendly" do
        @result.group_query_duration_in_seconds = 10
        @result.group_query_duration_to_s.should == "10 seconds"
      end

      it "should support nil" do
        @result.group_query_duration_in_seconds = nil
        @result.group_query_duration_to_s.should == "N/A"
      end
      
    end

    
    describe "#host_to_s" do
      
      it "should take host if set (but not db_host)" do
        @result.host = "a"
        @result.host_to_s.should == "a"
      end
      
      it "should only show name once if host and db_host the same" do
        @result.host = "b"
        @result.db_host = "b"
        @result.host_to_s.should == "b"
      end
      
      it "should take db_host if set (but not host)" do
        @result.db_host = "c"
        @result.host_to_s.should == "c"
      end

      it "should both hosts if they conflict" do
        @result.host = "a"
        @result.db_host = "b"
        @result.host_to_s.should == "a (host), b (db_host)"
      end
      
      
    end
    
    describe "#date_to_s" do

      it "should handle nil" do
        @result.date_to_s.should == ""
      end

      it "should handle a from date only without a created_at date" do
        @result.from_date = Time.parse("2010-01-02 03:04:05")
        @result.date_to_s.should == "2010-01-02 to present"
      end

      it "should return one date if 'today'" do
        @result.from_date = Time.parse("2010-01-02 03:04:05")
        @result.to_date = Time.parse("2010-01-02 04:05:06")
        @result.date_to_s.should == "2010-01-02"
      end
      
      it "should handle a from date only" do
        @result.from_date = Time.parse("2010-01-02 03:04:05")
        @result.save
        @result.date_to_s.should == "2010-01-02 to 2010-09-21"
      end

      it "should handle a to date only" do
        @result.to_date = Time.parse("2010-01-02 03:04:05")
        @result.date_to_s.should == "up to 2010-01-02"
      end

      it "should handle both a from and to date only" do
        @result.from_date = Time.parse("2009-01-02 03:04:05")
        @result.to_date = Time.parse("2010-01-02 03:04:05")
        @result.date_to_s.should == "2009-01-02 to 2010-01-02"
      end

      
    end
    
    describe "#from_date_to_s" do
      
      it "should handle nil" do
        @result.from_date_to_s.should == ""
      end
      
      it "should handle a date" do
        @result.from_date = Time.parse("2010-01-02 03:04:05")
        @result.from_date_to_s.should == "2010-01-02"
      end
      
    end

    describe "#to_date_to_s" do
      
      it "should handle nil" do
        @result.to_date_to_s.should == ""
      end
      
      it "should handle a date" do
        @result.to_date = Time.parse("2010-01-02 03:04:06")
        @result.to_date_to_s.should == "2010-01-02"
      end
      
    end

    describe "#sub_results" do
      
      it "should be empty be default" do
        @result.sub_results.should == []
      end
      
      it "should order by count" do
        @result = Result.create
        sub1 = SubResult.create(:count => 10)
        sub2 = SubResult.create(:count => 20)
        sub3 = SubResult.create(:count => 30)

        @result.sub_results<< sub1
        @result.sub_results<< sub3
        @result.sub_results<< sub2

        @result.save.should == true
        @result.reload

        @result.sub_results.should == [sub3,sub2,sub1]
      end
      
    end
    
    describe "#after_save" do
      
      before(:each) do
        Appstats::Result.delete_all
      end

      it "should only fix yourself" do
        Time.stub!(:now).and_return(Time.parse('2011-09-21 23:15:20'))
        new_result = Appstats::Result.create(:query => '# x')
        another_new_result = Appstats::Result.create(:query => '# y')
        Time.stub!(:now).and_return(Time.parse('2010-09-21 23:15:20'))
        another_old_result = Appstats::Result.create(:query => '# y')
        Appstats.connection.update('update appstats_results set is_latest = null')

        old_result = Appstats::Result.create(:query => '# x')
        
        new_result.reload and old_result.reload and another_new_result.reload and another_old_result.reload
        new_result.is_latest?.should == true
        old_result.is_latest?.should == false
        another_new_result.is_latest?.should == false
        another_old_result.is_latest?.should == false
      end
      
    end
    
    describe "#fix_all_is_latest" do
      
      before(:each) do
        Appstats::Result.delete_all
      end
      
      it "should work for no results" do
        Appstats::Result.fix_all_is_latest
      end
      
      it "should fix all resutls" do
        Time.stub!(:now).and_return(Time.parse('2011-09-21 23:15:20'))
        new_result = Appstats::Result.create(:query => '# x')
        Time.stub!(:now).and_return(Time.parse('2010-09-21 23:15:20'))
        old_result = Appstats::Result.create(:query => '# x')
        another_result = Appstats::Result.create(:query => '# y')
        Appstats.connection.update('update appstats_results set is_latest = null')
        
        Appstats::Result.fix_all_is_latest
        
        new_result.reload and old_result.reload and another_result.reload
        new_result.is_latest?.should == true
        old_result.is_latest?.should == false
        another_result.is_latest?.should == true
      end
      
    end
    
    describe "#count_to_s" do
      
      it "should handle nil" do
        @result.count = nil
        @result.count_to_s.should == '--'
      end
      
      it "should handle 0" do
        @result.count = 0
        @result.count_to_s.should == '0'
      end
      
      it "should handle < 1000 numbers" do
        @result.count = 123
        @result.count_to_s.should == "123"
      end

      it "should handle > 1000 numbers" do
        @result.count = 1000
        @result.count_to_s.should == "1,000"

        @result.count = 12345
        @result.count_to_s.should == "12,345"

      end

      it "should handle > 1000000 numbers" do
        @result.count = 1000000
        @result.count_to_s.should == "1,000,000"

        @result.count = 1234567
        @result.count_to_s.should == "1,234,567"
      end
      
      describe "short_hand format" do

        
        it "should handle trillion" do
          @result.count = 1400000000000
          @result.count_to_s(:format => :short_hand).should == "1.4 trillion"
        end

        it "should handle billion" do
          @result.count = 1490000000
          @result.count_to_s(:format => :short_hand).should == "1.5 billion"

          @result.count = 91490000000
          @result.count_to_s(:format => :short_hand).should == "91.5 billion"

        end

        it "should handle million" do
          @result.count = 1200000
          @result.count_to_s(:format => :short_hand).should == "1.2 million"

          @result.count = 881200000
          @result.count_to_s(:format => :short_hand).should == "881.2 million"
        end

        it "should handle thousand" do
          @result.count = 1200
          @result.count_to_s(:format => :short_hand).should == "1.2 thousand"

          @result.count = 912600
          @result.count_to_s(:format => :short_hand).should == "912.6 thousand"

        end

        it "should not display decimal if 0" do
          @result.count = 1000
          @result.count_to_s(:format => :short_hand).should == "1 thousand"

          @result.count = 912000
          @result.count_to_s(:format => :short_hand).should == "912 thousand"

        end
      end
    end
    
  end
end