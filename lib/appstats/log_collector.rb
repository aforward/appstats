require 'net/ssh'
require 'net/scp'

module Appstats
  class LogCollector < ActiveRecord::Base
    set_table_name "appstats_log_collectors"
  
    attr_accessible :host, :filename, :status

    def local_filename
      File.expand_path("#{File.dirname(__FILE__)}/../../log/appstats_remote_log_#{id}.log")
    end

    def self.find_remote_files(remote_login,path,log_template)
      begin
        Appstats.log(:info,"Looking for logs in [#{remote_login[:user]}@#{remote_login[:host]}:#{path}] labelled [#{log_template}]")
        Net::SSH.start(remote_login[:host], remote_login[:user], :password => remote_login[:password] ) do |ssh|
         all_files = ssh.exec!("cd #{path} && ls | grep #{log_template}").split
         load_remote_files(remote_login,path,all_files)
        end
      rescue Exception => e
        Appstats.log(:error,"Something bad occurred during Appstats::LogCollector.find_remote_files")
        Appstats.log(:error,e.message)
        0
      end
    end
    
    def self.load_remote_files(remote_login,path,all_files)
      count = 0
      Appstats.log(:info, "About to analyze #{all_files.size} file(s).")
      all_files.each do |log_name|
        filename = File.join(path,log_name)
        if LogCollector.find_by_host_and_filename(remote_login[:host],filename).nil?
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
      normalized_logins = {}
      raw_logins.each do |login|
        normalized_logins[login[:host]] = login
      end
      count = 0
      all = LogCollector.where("status = 'unprocessed'").all
      Appstats.log(:info,"About to download #{all.size} file(s).")
      all.each do |log_collector|
        host = log_collector.host
        user = normalized_logins[host][:user]
        password = normalized_logins[host][:password]
        begin
          Net::SCP.start( host, user, :password => password ) do |scp|
            scp.download!( log_collector.filename, log_collector.local_filename )
          end
        rescue Exception => e
          Appstats.log(:error,"Something bad occurred during Appstats::LogCollector.download_remote_files")
          Appstats.log(:error,e.message)
        end
        if File.exists?(log_collector.local_filename)
          Appstats.log(:info,"  - #{user}@#{host}:#{log_collector.filename} > #{log_collector.local_filename}")
          log_collector.status = 'downloaded'
          count += 1  
        else
          Appstats.log(:error, "File #{log_collector.local_filename} did not download.")
          log_collector.status = 'failed_download'
        end
        log_collector.save
      end
      Appstats.log(:info,"Downloaded #{count} file(s).")
      count
    end
  
  end
  
end