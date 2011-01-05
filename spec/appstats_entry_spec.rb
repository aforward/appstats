require 'spec_helper'

describe AppstatsEntry do

  describe "#initialize" do

    before(:each) do
      @entry = AppstatsEntry.new
    end
    
    it "should set entry_type to nil" do
      @entry.entry_type.should == nil
    end

    it "should set name to nil" do
      @entry.name.should == nil
    end
    
    it "should set description to nil" do
      @entry.description.should == nil
    end
    
    it "should set on constructor" do
      entry = AppstatsEntry.new(:entry_type => 'a', :name => 'b', :description => 'c')
      entry.entry_type.should == 'a'
      entry.name.should == 'b'
      entry.description.should == 'c'
    end
    
  end

  describe "#to_s" do
    
    before(:each) do
      @entry = AppstatsEntry.new
    end
    
    it "should run the test" do
      @entry.to_s.should == 'Entry [type],[name],[description]'
    end
  end
end