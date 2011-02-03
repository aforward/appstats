require 'spec_helper'

module Appstats
  describe Context do

    before(:each) do
      @context = Appstats::Context.new
      @time = Time.parse('2010-01-02 10:20:30')
    end

    describe "#initialize" do

      it "should set context_key to nil" do
        @context.context_key.should == nil
      end

      it "should set context_value to nil" do
        @context.context_value.should == nil
      end
      
      it "should set context_int to nil" do
        @context.context_int.should == nil
      end

      it "should set context_float to nil" do
        @context.context_float.should == nil
      end

      it "should set on constructor" do
        context = Appstats::Context.new(:context_key => 'a', :context_value => "b", :context_int => 1, :context_float => 1.3)
        context.context_key.should == 'a'
        context.context_value.should == 'b'
        context.context_int.should == nil
        context.context_float.should == nil
      end
    
    end

    describe "#context_int" do
    
      it "should be nil if not an int" do
        @context.context_int.should == nil
        @context.context_value = "1"
        @context.context_int.should == 1

        @context.context_value = "2"
        @context.context_int.should == 2
       
        @context.context_value = "c"
        @context.context_int.should == nil

        @context.context_value = nil
        @context.context_int.should == nil

      end
    
    end

    describe "#context_float" do

      it "should be nil if not an int" do
        @context.context_float.should == nil
        @context.context_value = "1"
        @context.context_float.should == 1.0

        @context.context_value = "2.1"
        @context.context_float.should == 2.1
       
        @context.context_value = "c"
        @context.context_float.should == nil

        @context.context_value = nil
        @context.context_float.should == nil

      end      
    end
    
    describe "#entry" do
      
      before(:each) do
        @entry = Appstats::Entry.new(:action => "a")
        @entry.save.should == true
      end
      
      it "should have an entry" do
        @context.entry.should == nil
        @context.entry = @entry
        @context.save.should == true
        @context.reload
        @context.entry.should == @entry
      end
      
    end

    describe "#to_s" do
    
      before(:each) do
        @context = Appstats::Context.new
      end
    
      it "should return no context if no key" do
        @context.to_s.should == 'No Context'
        @context.context_key = ''
        @context.to_s.should == 'No Context'
      end
      
      it "should return the context_key name if no date" do
        @context.context_key = "Blah"
        @context.to_s.should == 'Blah[]'
      end
      
      it "should return context_key and context_value if available" do
        @context.context_key = "More Blah"
        @context.context_value = "true"
        @context.to_s.should == "More Blah[true]"
      end
      
    end
  end
end