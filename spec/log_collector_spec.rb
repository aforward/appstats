require 'spec_helper'

module Appstats
  describe LogCollector do

    before(:each) do
      @log_collector = Appstats::LogCollector.new
      @login = { :host => "myhost.localnet", :user => "deployer", :password => "pass" }
      @login2 = { :host => "yourhost.localnet", :user => "deployer", :password => "ssap" }
      @logins = [@login2, @login]
    end
    
    def simple_path(local_path_to_filename)
      File.expand_path("#{File.dirname(__FILE__)}/#{local_path_to_filename}")
    end

    describe "#initialize" do

      it "should set host to nil" do
        @log_collector.host.should == nil
      end

      it "should set filename to nil" do
        @log_collector.filename.should == nil
      end
      
      it "should set status to unprocessed" do
        @log_collector.status.should == nil
      end
    
      it "should set on constructor" do
        log_collector = Appstats::LogCollector.new(:host => 'a', :filename => 'b', :status => 'c')
        log_collector.host.should == 'a'
        log_collector.filename.should == 'b'
        log_collector.status.should == 'c'
      end
    
    end
    
    describe "#find_remote_files" do
      
      before(:each) do
        LogCollector.delete_all
        @before_count = LogCollector.count
      end
      
      it "should log all transactions" do
        ssh = mock(Net::SSH)
        Net::SSH.should_receive(:start).with("myhost.localnet","deployer",{ :password => "pass"}).and_yield(ssh)
        ssh.should_receive(:exec!).with("cd /my/path/log && ls | grep mystats").and_return("mystats1\nmystats2")
        
        Appstats.should_receive(:log).with(:info, "Looking for logs in [deployer@myhost.localnet:/my/path/log] labelled [mystats]")
        Appstats.should_receive(:log).with(:info, "About to analyze 2 file(s).")
        Appstats.should_receive(:log).with(:info, "  - deployer@myhost.localnet:/my/path/log/mystats1")
        Appstats.should_receive(:log).with(:info, "  - deployer@myhost.localnet:/my/path/log/mystats2")
        Appstats.should_receive(:log).with(:info, "Loaded 2 file(s).")
        LogCollector.find_remote_files(@login,"/my/path/log","mystats").should == 2
      end
      
      it "should talk to remote server" do
        ssh = mock(Net::SSH)
        Net::SSH.should_receive(:start).with("myhost.localnet","deployer",{ :password => "pass"}).and_yield(ssh)
        ssh.should_receive(:exec!).with("cd /my/path/log && ls | grep mystats").and_return("mystats1\nmystats2")
        
        LogCollector.find_remote_files(@login,"/my/path/log","mystats").should == 2
        LogCollector.count.should == @before_count + 2

        log_collector = LogCollector.last
        log_collector.host.should == "myhost.localnet"
        log_collector.filename.should == "/my/path/log/mystats2"
        log_collector.status.should == "unprocessed"
      end
      
      it "should fail silently for bad connections" do
        Net::SSH.should_receive(:start).with("myhost.localnet","deployer",{ :password => "pass"}).and_raise("Some bad message")
        Appstats.should_receive(:log).with(:info, "Looking for logs in [deployer@myhost.localnet:/my/path/log] labelled [mystats]")
        Appstats.should_receive(:log).with(:error,"Something bad occurred during Appstats::LogCollector.find_remote_files")
        Appstats.should_receive(:log).with(:error,"Some bad message")
        LogCollector.find_remote_files(@login,"/my/path/log","mystats").should == 0
      end
      
    end
    
    describe "#load_remote_files" do
      
      before(:each) do
        LogCollector.delete_all
        @before_count = LogCollector.count
      end
      
      it "should log the files loaded" do
        LogCollector.load_remote_files(@login,"/my/path/log",["app2"]).should == 1
        
        Appstats.should_receive(:log).with(:info, "About to analyze 3 file(s).")
        Appstats.should_receive(:log).with(:info, "  - deployer@myhost.localnet:/my/path/log/app1")
        Appstats.should_receive(:log).with(:info, "  - ALREADY LOADED deployer@myhost.localnet:/my/path/log/app2")
        Appstats.should_receive(:log).with(:info, "  - deployer@myhost.localnet:/my/path/log/app3")
        Appstats.should_receive(:log).with(:info, "Loaded 2 file(s).")
        LogCollector.load_remote_files(@login,"/my/path/log",["app1","app2","app3"]).should == 2
      end
      
      it "should create an unprocessed record per file" do
        LogCollector.load_remote_files(@login,"/my/path/log",["app1","app2","app3"]).should == 3
        LogCollector.count.should == @before_count + 3
        log_collector = LogCollector.last
        
        log_collector.host.should == "myhost.localnet"
        log_collector.filename.should == "/my/path/log/app3"
        log_collector.status.should == "unprocessed"
      end
      
      it "should ignore the same file" do
        LogCollector.load_remote_files(@login,"/my/path/log",["app1","app3"]).should == 2
        LogCollector.load_remote_files(@login,"/my/path/log",["app1","app2","app3"]).should == 1
        LogCollector.count.should == @before_count + 3
        log_collector = LogCollector.last
        
        log_collector.host.should == "myhost.localnet"
        log_collector.filename.should == "/my/path/log/app2"
        log_collector.status.should == "unprocessed"
      end
      
    end
    
    describe "#local_filename" do
      
      it "should return a standardized name with the log collector id" do
        log = LogCollector.create
        log.local_filename.should == simple_path("../log/appstats_remote_log_#{log.id}.log")
      end
      
    end
    
    describe "#download_remote_files" do

      before(:each) do
        @delete_mes = []
        LogCollector.delete_all
        @before_count = LogCollector.count
      end
      
      after(:each) do
        @delete_mes.each do |filename|
          File.delete(filename) if File.exists?(filename)
        end
      end
      
      it "should log exceptions" do
        LogCollector.load_remote_files(@login,"/my/path/log",["app1"]).should == 1
        log1 = LogCollector.find_by_filename("/my/path/log/app1")
        @delete_mes<< log1.local_filename

        scp = mock(Net::SCP)
        Net::SCP.should_receive(:start).with("myhost.localnet","deployer",{ :password => "pass"}).and_yield(scp)
        scp.should_receive(:download!).with("/my/path/log/app1",simple_path("../log/appstats_remote_log_#{log1.id}.log")).and_raise("Something bad happened again")

        Appstats.should_receive(:log).with(:info,"About to download 1 file(s).")
        Appstats.should_receive(:log).with(:error,"Something bad occurred during Appstats::LogCollector.download_remote_files")
        Appstats.should_receive(:log).with(:error,"Something bad happened again")
        Appstats.should_receive(:log).with(:error, "File #{simple_path("../log/appstats_remote_log_#{log1.id}.log")} did not download.")
        Appstats.should_receive(:log).with(:info,"Downloaded 0 file(s).")
        LogCollector.download_remote_files(@logins).should == 0
      end
      
      it "should ignore if file not downloaded" do
        LogCollector.load_remote_files(@login,"/my/path/log",["app1"]).should == 1
        log1 = LogCollector.find_by_filename("/my/path/log/app1")
        @delete_mes<< log1.local_filename

        scp = mock(Net::SCP)
        Net::SCP.should_receive(:start).with("myhost.localnet","deployer",{ :password => "pass"}).and_yield(scp)
        scp.should_receive(:download!).with("/my/path/log/app1",simple_path("../log/appstats_remote_log_#{log1.id}.log"))
        
        Appstats.should_receive(:log).with(:info,"About to download 1 file(s).")        
        Appstats.should_receive(:log).with(:error, "File #{simple_path("../log/appstats_remote_log_#{log1.id}.log")} did not download.")
        Appstats.should_receive(:log).with(:info,"Downloaded 0 file(s).")
        LogCollector.download_remote_files(@logins).should == 0
        log1.reload
        log1.status.should == "failed_download"
      end
      
      it "should copy the file based on the log_collector id" do
        LogCollector.load_remote_files(@login,"/my/path/log",["app1","app2"]).should == 2
        
        log1 = LogCollector.find_by_filename("/my/path/log/app1")
        log2 = LogCollector.find_by_filename("/my/path/log/app2")
        @delete_mes<< log1.local_filename
        @delete_mes<< log2.local_filename
        
        File.open(log1.local_filename, 'w') {|f| f.write("testfile - delete") }
        File.open(log2.local_filename, 'w') {|f| f.write("testfile - delete") }


        scp = mock(Net::SCP)
        1.upto(3) do
          Net::SCP.should_receive(:start).with("myhost.localnet","deployer",{ :password => "pass"}).and_yield(scp)
        end
        scp.should_receive(:download!).with("/my/path/log/app1",simple_path("../log/appstats_remote_log_#{log1.id}.log"))
        scp.should_receive(:download!).with("/my/path/log/app2",simple_path("../log/appstats_remote_log_#{log2.id}.log"))
        
        LogCollector.download_remote_files(@logins).should == 2
        
        log1.reload and log2.reload
        log1.status.should == "downloaded"
        log2.status.should == "downloaded"
        
        LogCollector.load_remote_files(@login,"/my/path/log",["app3"]).should == 1
        log3 = LogCollector.find_by_filename("/my/path/log/app3")
        @delete_mes<< log3.local_filename
        File.open(log3.local_filename, 'w') {|f| f.write("testfile - delete") }
        
        localfile = simple_path("../log/appstats_remote_log_#{log3.id}.log")
        scp.should_receive(:download!).with("/my/path/log/app3",localfile)

        Appstats.should_receive(:log).with(:info,"About to download 1 file(s).")
        Appstats.should_receive(:log).with(:info, "  - deployer@myhost.localnet:/my/path/log/app3 > #{localfile}")
        Appstats.should_receive(:log).with(:info,"Downloaded 1 file(s).")
        LogCollector.download_remote_files(@logins).should == 1
        log3.reload and log3.reload
        log3.status.should == "downloaded"
      end
      
    end
  end
end
