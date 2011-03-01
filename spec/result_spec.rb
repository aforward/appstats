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
        @result.query_as_sql.should == nil
        @result.count.should == nil
        @result.action.should == nil
        @result.contexts.should == nil
        @result.from_date.should == nil
        @result.to_date.should == nil
      end
    
      it "should set on constructor" do
        result = Appstats::Result.new(:name => 'a', :result_type => 'b', :query => 'c', :query_as_sql => 'd', :count => 10, :action => 'e', :host => 'f', :contexts => 'g', :from_date => Time.parse("2010-01-02"), :to_date => Time.parse("2010-02-03"))
        result.name.should == 'a'
        result.result_type.should == 'b'
        result.query.should == 'c'
        result.query_as_sql.should == 'd'
        result.count.should == 10
        result.action.should == 'e'
        result.host.should == 'f'
        result.contexts.should == 'g'
        result.from_date_to_s.should == '2010-01-02'
        result.to_date_to_s.should == '2010-02-03'
      end
    
    end
    
    describe "#==" do
      
      it "should be equal on all attributes" do
        result = Appstats::Result.new(:name => 'a', :result_type => 'b', :query => 'c', :query_as_sql => 'd', :count => 10, :action => 'e', :host => 'f', :contexts => 'g', :from_date => Time.parse("2010-01-02"), :to_date => Time.parse("2010-02-03"))
        same_result = Appstats::Result.new(:name => 'a', :result_type => 'b', :query => 'c', :query_as_sql => 'd', :count => 10, :action => 'e', :host => 'f', :contexts => 'g', :from_date => Time.parse("2010-01-02"), :to_date => Time.parse("2010-02-03"))
        (result == same_result).should == true
      end
      
      it "should be not equal if diferent attributes" do
        result = Appstats::Result.new(:name => 'a', :result_type => 'b', :query => 'c', :query_as_sql => 'd', :count => 10, :action => 'e', :host => 'f', :contexts => 'g', :from_date => Time.parse("2010-01-02"), :to_date => Time.parse("2010-02-03"))
        
        [:name,:result_type,:query,:query_as_sql,:count,:action,:host,:contexts,:from_date,:to_date].each do |attr|
          different_result = Appstats::Result.new(:name => 'a', :result_type => 'b', :query => 'c', :query_as_sql => 'd', :count => 10, :action => 'e', :host => 'f', :contexts => 'g', :from_date => Time.parse("2010-01-02"), :to_date => Time.parse("2010-02-03"))  

          if [:from_date,:to_date].include?(attr)
            different_result.send("#{attr}=",Time.parse("2011-01-02"))
          else
            different_result.send("#{attr}=","XXX")
          end
          
          different_result.should_not == result
        end
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
    
  end
end