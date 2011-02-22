require 'spec_helper'

module Appstats
  describe LogCollector do

    before(:each) do
      @time = Time.parse('2010-01-03 10:20:30')
      Time.stub!(:now).and_return(@time)

      LogCollector.delete_all
      @log_collector = Appstats::LogCollector.new
      @login = { :host => "myhost.localnet", :user => "deployer", :password => "pass" }
      @login2 = { :host => "yourhost.localnet", :user => "deployer", :password => "ssap" }
      @logins = [@login2, @login]
    end
    
    after(:each) do
      LogCollector.all.each do |log_collector|
        File.delete(log_collector.local_filename) if File.exists?(log_collector.local_filename)
      end
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
    
    
    describe "#processed_filename" do
      
      it "should handle nil filename" do
        LogCollector.new.processed_filename.should == nil
        LogCollector.new(:filename => "").processed_filename.should == ""
      end
      
      it "should handle filenames without slashes" do
        LogCollector.new(:filename => "blah_blah_blah").processed_filename.should == "__processed__blah_blah_blah"
      end

      it "should handle filenames with one slash" do
        LogCollector.new(:filename => "/blah_blah_blah").processed_filename.should == "/__processed__blah_blah_blah"
      end

      it "should handle filenames with many slash" do
        LogCollector.new(:filename => "one/two/three/blah_blah_blah").processed_filename.should == "one/two/three/__processed__blah_blah_blah"
        LogCollector.new(:filename => "/one/two/blah_blah_blah").processed_filename.should == "/one/two/__processed__blah_blah_blah"
      end
      
      
    end
    
    describe "#find_remote_files" do
      
      before(:each) do
        @before_count = LogCollector.count
      end
      
      it "should log all transactions" do
        ssh = mock(Net::SSH)
        Net::SSH.should_receive(:start).with("myhost.localnet","deployer",{ :password => "pass"}).and_yield(ssh)
        ssh.should_receive(:exec!).with("cd /my/path/log && ls -tr | grep mystats").and_return("mystats_2010-01-01.log\nmystats_2010-01-02.log\nmystats_2010-01-03.log")

        Appstats.should_receive(:log).with(:info, "Looking for logs in [deployer@myhost.localnet:/my/path/log] labelled [mystats]")
        Appstats.should_receive(:log).with(:info, "About to analyze 3 file(s).")
        Appstats.should_receive(:log).with(:info, "  - deployer@myhost.localnet:/my/path/log/mystats_2010-01-01.log")
        Appstats.should_receive(:log).with(:info, "  - deployer@myhost.localnet:/my/path/log/mystats_2010-01-02.log")
        Appstats.should_receive(:log).with(:info, "  - IGNORING CURRENT LOG FILE deployer@myhost.localnet:/my/path/log/mystats_2010-01-03.log")
        Appstats.should_receive(:log).with(:info, "Loaded 2 file(s).")
        LogCollector.find_remote_files(@login,"/my/path/log","mystats").should == 2
      end
      
      it "should talk to remote server" do
        ssh = mock(Net::SSH)
        Net::SSH.should_receive(:start).with("myhost.localnet","deployer",{ :password => "pass"}).and_yield(ssh)
        ssh.should_receive(:exec!).with("cd /my/path/log && ls -tr | grep mystats").and_return("mystats_2010-01-01.log\nmystats_2010-01-02.log")
        
        LogCollector.find_remote_files(@login,"/my/path/log","mystats").should == 2
        LogCollector.count.should == @before_count + 2

        log_collector = LogCollector.last
        log_collector.host.should == "myhost.localnet"
        log_collector.filename.should == "/my/path/log/mystats_2010-01-02.log"
        log_collector.status.should == "unprocessed"
      end
      
      it "should fail silently for bad connections" do
        Net::SSH.should_receive(:start).with("myhost.localnet","deployer",{ :password => "pass"}).and_raise("Some bad message")
        Appstats.should_receive(:log).with(:info, "Looking for logs in [deployer@myhost.localnet:/my/path/log] labelled [mystats]")
        Appstats.should_receive(:log).with(:error,"Something bad occurred during Appstats::LogCollector#find_remote_files")
        Appstats.should_receive(:log).with(:error,"Some bad message")
        LogCollector.find_remote_files(@login,"/my/path/log","mystats").should == 0
      end
      
    end
    
    describe "#load_remote_files" do
      
      before(:each) do
        @before_count = LogCollector.count
      end

      it "should log if nothing to load" do
        log = LogCollector.create(:status => "not_unprocessed")
        Appstats.should_receive(:log).with(:info,"No remote logs to load.")
        LogCollector.load_remote_files(@login,"/my/path/log",[]).should == 0
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

      it "should ignore today's file" do
        Appstats.should_receive(:log).with(:info, "About to analyze 3 file(s).")
        Appstats.should_receive(:log).with(:info, "  - deployer@myhost.localnet:/my/path/log/app1")
        Appstats.should_receive(:log).with(:info, "  - deployer@myhost.localnet:/my/path/log/app2")
        Appstats.should_receive(:log).with(:info, "  - IGNORING CURRENT LOG FILE deployer@myhost.localnet:/my/path/log/app3_2010-01-03.log")
        Appstats.should_receive(:log).with(:info, "Loaded 2 file(s).")
        LogCollector.load_remote_files(@login,"/my/path/log",["app1","app2","app3_2010-01-03.log"]).should == 2
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
        @before_count = LogCollector.count
      end
      
      it "should only process unprocessed files" do
        log = LogCollector.create(:status => "not_unprocessed")
        Appstats.should_receive(:log).with(:info,"No remote logs to download.")
        LogCollector.download_remote_files(@logins).should == 0
      end
      
      it "should log exceptions" do
        LogCollector.load_remote_files(@login,"/my/path/log",["app1"]).should == 1
        log1 = LogCollector.find_by_filename("/my/path/log/app1")

        scp = mock(Net::SCP)
        Net::SCP.should_receive(:start).with("myhost.localnet","deployer",{ :password => "pass"}).and_yield(scp)
        scp.should_receive(:download!).with("/my/path/log/app1",simple_path("../log/appstats_remote_log_#{log1.id}.log")).and_raise("Something bad happened again")

        Appstats.should_receive(:log).with(:info,"About to download 1 file(s).")
        Appstats.should_receive(:log).with(:error,"Something bad occurred during Appstats::LogCollector#download_remote_files")
        Appstats.should_receive(:log).with(:error,"Something bad happened again")
        Appstats.should_receive(:log).with(:error, "File #{simple_path("../log/appstats_remote_log_#{log1.id}.log")} did not download.")
        Appstats.should_receive(:log).with(:info,"Downloaded 0 file(s).")
        LogCollector.download_remote_files(@logins).should == 0
      end
      
      it "should ignore if file not downloaded" do
        LogCollector.load_remote_files(@login,"/my/path/log",["app1"]).should == 1
        log1 = LogCollector.find_by_filename("/my/path/log/app1")

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
    
    describe "#process_local_files" do
      
      before(:each) do
        @entry_count = Entry.count
      end
      
      it "should only process downloaded files" do
        log = LogCollector.create(:status => "not_downloaded")
        Appstats.should_receive(:log).with(:info,"No local logs to process.")
        LogCollector.process_local_files.should == 0
      end

      it "should process downloaded files into entries" do
        LogCollector.load_remote_files(@login,"/my/path/log",["appstats1"]).should == 1
        log3 = LogCollector.find_by_filename("/my/path/log/appstats1")
        log3.status = "downloaded" and log3.save.should == true
        File.open(log3.local_filename, 'w') {|f| f.write(Appstats::Logger.entry_to_s("test_action1") + "\n" + Appstats::Logger.entry_to_s("test_action2")) }

        Appstats.should_receive(:log).with(:info,"About to process 1 file(s).")
        Appstats.should_receive(:log).with(:info,"  - 2 entr(ies) in #{log3.local_filename}.")
        Appstats.should_receive(:log).with(:info,"Processed 1 file(s) with 2 entr(ies).")
        LogCollector.process_local_files.should == 1
        
        log3.reload
        log3.status.should == "processed"
        Entry.count.should == @entry_count + 2
        entry = Entry.last
        entry.log_collector.should == log3
        entry.action.should == "test_action2"
      end
      
      it "should deal with exceptions" do
        LogCollector.load_remote_files(@login,"/my/path/log",["appstats1"]).should == 1
        log3 = LogCollector.find_by_filename("/my/path/log/appstats1")
        log3.status = "downloaded" and log3.save.should == true
        File.open(log3.local_filename, 'w') {|f| f.write(Appstats::Logger.entry_to_s("test_action1") + "\n" + Appstats::Logger.entry_to_s("test_action2")) }

        File.stub!(:open).and_raise("bad error")
        
        Appstats.should_receive(:log).with(:info,"About to process 1 file(s).")
        Appstats.should_receive(:log).with(:error,"Something bad occurred during Appstats::LogCollector#process_local_files")
        Appstats.should_receive(:log).with(:error,"bad error")
        Appstats.should_receive(:log).with(:info,"Processed 0 file(s) with 0 entr(ies).")
        LogCollector.process_local_files.should == 0
        
        log3.reload
        log3.status.should == "downloaded"
        Entry.count.should == @entry_count
      end      
      
    end
    
    describe "#remove_remote_files" do

      before(:each) do
        @entry_count = Entry.count
      end
      
      it "should ignored non processed files" do
        log = LogCollector.create(:status => "blah")
        Appstats.should_receive(:log).with(:info,"No remote logs to remove.")
        Appstats::LogCollector.remove_remote_files(@login).should == 0
      end

      it "should log all transactions" do
        
        log1 = LogCollector.create(:status => "processed", :filename => "/my/path/log/mystats_2011-01-02.log", :host => "myhost.localnet")
        log2 = LogCollector.create(:status => "processed", :filename => "/my/path/log/mystats_2011-01-03.log", :host => "myhost.localnet")

        ssh = mock(Net::SSH)
        Net::SSH.should_receive(:start).twice.with("myhost.localnet","deployer",{ :password => "pass"}).and_yield(ssh)
        ssh.should_receive(:exec!).with("mv /my/path/log/mystats_2011-01-02.log /my/path/log/__processed__mystats_2011-01-02.log")
        ssh.should_receive(:exec!).with("mv /my/path/log/mystats_2011-01-03.log /my/path/log/__processed__mystats_2011-01-03.log")

        Appstats.should_receive(:log).with(:info, "About to remove 2 remote file(s) from the processing queue.")
        Appstats.should_receive(:log).with(:info, "  - deployer@myhost.localnet:/my/path/log/__processed__mystats_2011-01-02.log")
        Appstats.should_receive(:log).with(:info, "  - deployer@myhost.localnet:/my/path/log/__processed__mystats_2011-01-03.log")
        Appstats.should_receive(:log).with(:info, "Removed 2 remote file(s).")

        Appstats::LogCollector.remove_remote_files(@login).should == 2
        log1.reload and log2.reload
        log1.status.should == "destroyed"
        log2.status.should == "destroyed"
      end
    end
    
    describe "#should_process" do
      
      it "should be true for nil" do
        LogCollector.should_process(nil).should == true
      end
      
      it "should want an update if not in the same day" do
        last_time = Time.parse("2010-01-02")
        Time.stub!(:now).and_return(Time.parse('2010-01-03'))
        LogCollector.should_process(last_time).should == true
      end

      it "should not want an update if same day" do
        last_time = Time.parse("2010-01-02")
        Time.stub!(:now).and_return(Time.parse('2010-01-02'))
        LogCollector.should_process(last_time).should == false
      end
    end
    
    
  end
end
