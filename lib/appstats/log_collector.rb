require 'net/ssh'
require 'net/scp'

module Appstats
  class LogCollector < ActiveRecord::Base
    set_table_name "appstats_log_collectors"
    
    @@downloaded_log_directory = nil
    
    attr_accessible :host, :filename, :status, :local_filename
    has_many :entries, :table_name => 'appstats_entries', :foreign_key => 'appstats_log_collector_id', :order => 'action'

    def calculated_local_filename
      if Appstats::LogCollector.downloaded_log_directory.nil?
        File.expand_path("#{File.dirname(__FILE__)}/../../log/appstats_remote_log_#{id}.log")
      else
        File.expand_path("#{Appstats::LogCollector.downloaded_log_directory}/appstats_remote_log_#{id}.log")
      end
    end

    def processed_filename
      return filename if filename.nil? || filename == ''
      m = filename.match(/(.*\/)(.*)/)
      prefix = "__processed__"
      return "#{prefix}#{filename}" if m.nil?
      "#{m[1]}#{prefix}#{m[2]}"
    end

    def unprocess_entries
      return false unless ["processed","destroyed"].include?(status)
      entries.each do |entry|
        entry.destroy
      end
      self.status = "downloaded"
      save
      true
    end

    def self.downloaded_log_directory=(value)
      @@downloaded_log_directory = value
    end

    def self.downloaded_log_directory
      @@downloaded_log_directory
    end

    def self.should_process(last_time)
      return true if last_time.nil?
      Time.now.day > last_time.day
    end

    def self.find_remote_files(remote_login,path,log_template)
      begin
        Appstats.log(:info,"Looking for logs in [#{remote_login[:user]}@#{remote_login[:host]}:#{path}] labelled [#{log_template}]")
        Net::SSH.start(remote_login[:host], remote_login[:user], :password => remote_login[:password] ) do |ssh|
          raw_files = ssh.exec!("cd #{path} && ls -tr | grep #{log_template} | grep -v __processed__") 
          all_files = raw_files.nil? ? [] : raw_files.split
          load_remote_files(remote_login,path,all_files)
        end
      rescue Exception => e
        Appstats.log(:error,"Something bad occurred during Appstats::LogCollector#find_remote_files")
        Appstats.log(:error,e.message)
        0
      end
    end
    
    def self.load_remote_files(remote_login,path,all_files)
      if all_files.empty?
        Appstats.log(:info,"No remote logs to load.")
        return 0
      end

      count = 0
      Appstats.log(:info, "About to analyze #{all_files.size} file(s).")
      all_files.each do |log_name|
        filename = File.join(path,log_name)
        if !log_name.match("(.*)#{Time.now.strftime('%Y-%m-%d')}.log").nil?
          Appstats.log(:info, "  - IGNORING CURRENT LOG FILE #{remote_login[:user]}@#{remote_login[:host]}:#{filename}")
        elsif LogCollector.find_by_host_and_filename(remote_login[:host],filename).nil?
          log_collector = LogCollector.create(:host => remote_login[:host], :filename => filename, :status => "unprocessed")
          Appstats.log(:info, "  - #{remote_login[:user]}@#{remote_login[:host]}:#{filename}")
          count += 1
        else
          Appstats.log(:info, "  - ALREADY LOADED #{remote_login[:user]}@#{remote_login[:host]}:#{filename}")
        end
      end
      Appstats.log(:info, "Loaded #{count} file(s).")
      count
    end
    
    def self.download_remote_files(raw_logins)
      all = Appstats.rails3? ? LogCollector.where("status = 'unprocessed'").all : LogCollector.find(:all,:conditions => "status = 'unprocessed'")
      if all.empty?
        Appstats.log(:info,"No remote logs to download.")
        return 0
      end

      normalized_logins = normalize_logins(raw_logins)
      count = 0
      
      Appstats.log(:info,"About to download #{all.size} file(s).")
      all.each do |log_collector|
        host = log_collector.host
        user = normalized_logins[host][:user]
        password = normalized_logins[host][:password]
        begin
          Net::SCP.start( host, user, :password => password ) do |scp|
            scp.download!( log_collector.filename, log_collector.calculated_local_filename )
          end
        rescue Exception => e
          Appstats.log(:error,"Something bad occurred during Appstats::LogCollector#download_remote_files")
          Appstats.log(:error,e.message)
        end
        if File.exists?(log_collector.calculated_local_filename)
          log_collector.local_filename = log_collector.calculated_local_filename
          log_collector.status = 'downloaded'
          Appstats.log(:info,"  - #{user}@#{host}:#{log_collector.filename} > #{log_collector.local_filename}")
          count += 1  
        else
          Appstats.log(:error, "File #{log_collector.calculated_local_filename} did not download.")
          log_collector.status = 'failed_download'
        end
        log_collector.save
      end
      Appstats.log(:info,"Downloaded #{count} file(s).")
      count
    end
    
    def self.process_local_files
      all = Appstats.rails3? ? LogCollector.where("status = 'downloaded'").all : LogCollector.find(:all, :conditions => "status = 'downloaded'")
      if all.empty?
        Appstats.log(:info,"No local logs to process.")
        return 0
      end
      Appstats.log(:info,"About to process #{all.size} file(s).")
      count = 0
      total_entries = 0
      all.each do |log_collector|
        current_entries = 0
        begin
          File.open(log_collector.local_filename,"r").readlines.each do |line|
            entry = Entry.create_from_logger_string(line.strip)
            entry.log_collector = log_collector
            entry.save
            current_entries += 1
            total_entries += 1
          end
          Appstats.log(:info,"  - #{current_entries} entr(ies) in #{log_collector.local_filename}.")
          log_collector.status = "processed"
          log_collector.save
          count += 1
        rescue Exception => e
          Appstats.log(:error,"Something bad occurred during Appstats::LogCollector#process_local_files")
          Appstats.log(:error,e.message)
        end
      end
      Appstats.log(:info,"Processed #{count} file(s) with #{total_entries} entr(ies).")
      count
    end

    def self.remove_remote_files(raw_logins)
      all = Appstats.rails3? ? LogCollector.where("status = 'processed'").all : LogCollector.find(:all,:conditions => "status = 'processed'")
      if all.empty?
        Appstats.log(:info,"No remote logs to remove.")
        return 0
      end
      
      normalized_logins = normalize_logins(raw_logins)
      
      count = 0
      Appstats.log(:info,"About to remove #{all.size} remote file(s) from the processing queue.")
      all.each do |log_collector|
        host = log_collector.host
        
        if normalized_logins[host].nil?
          Appstats.log(:info,"  - Missing host login details [#{host}], unable to remove #{log_collector.processed_filename}")
          next
        end
        
        user = normalized_logins[host][:user]
        password = normalized_logins[host][:password]

        Net::SSH.start(host, user, :password => password ) do |ssh|
         ssh.exec!("mv #{log_collector.filename} #{log_collector.processed_filename}")
         Appstats.log(:info,"  - #{user}@#{host}:#{log_collector.processed_filename}")
         log_collector.status = "destroyed"
         log_collector.save
         count += 1
        end
      end
      Appstats.log(:info,"Removed #{count} remote file(s).")
      count
    end
    
    def self.normalize_logins(raw_logins)
      normalized_logins = {}
      raw_logins.each do |login|
        normalized_logins[login[:host]] = login
      end
      normalized_logins
    end
  
  end
end