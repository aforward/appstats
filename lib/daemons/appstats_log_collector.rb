#!/usr/bin/env ruby

$running = true
Signal.trap("TERM") do 
  $running = false
end

options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage #{File.basename(__FILE__)} [options]"
  options[:config] = "./appstats.config"
  opts.on( '--config FILE', 'Contains information about the databsae connection and the files to read' ) do |file|
    options[:config] = file
  end
  options[:logfile] = "./appstats.log"
  opts.on( '--logfile FILE', 'Write log to file' ) do |file|
    options[:logfile] = file
  end
end
optparse.parse!

require 'logger'
$logger = Logger.new(options[:logfile])
unless File.exists?(options[:config])
  Appstats.log(:info,"Cannot find config file [#{options[:config]}]")
  exit(1)
end

Appstats.log(:info,"Started Appstats Log Collector")
require File.join(File.dirname(__FILE__),"..","appstats")
last_processed_at = nil

while($running) do

  appstats_config = YAML::load(File.open(options[:config]))
  ActiveRecord::Base.establish_connection(appstats_config['database'])

  unless Appstats::LogCollector.should_process(last_processed_at)
    an_hour = 60*60
    sleep an_hour
    next
  end

  if appstats_config['downloaded_log_directory'].nil?
    Appstats.log(:info,"Logs will be downloaded to default directory (downloaded_log_directory in config file to overwrite")
  else
    Appstats::LogCollector.downloaded_log_directory = appstats_config['downloaded_log_directory']
    Appstats.log(:info,"Logs will be downloaded to #{Appstats::LogCollector.downloaded_log_directory}")
  end

  last_processed_at = Time.now
  ActiveRecord::Base.connection.reconnect!
  appstats_config["remote_servers"].each do |remote_server|
    Appstats::LogCollector.find_remote_files(remote_server,remote_server[:path],remote_server[:template])
  end
  Appstats::LogCollector.download_remote_files(appstats_config["remote_servers"])
  Appstats::LogCollector.process_local_files

  Appstats::ResultJob.require_third_party_queries(appstats_config["third_party_queries"])
  Appstats::ResultJob.run

  Appstats::Action.update_actions
  Appstats::Host.update_hosts
  Appstats::ContextKey.update_context_keys
  Appstats::ContextValue.update_context_values
  Appstats::LogCollector.remove_remote_files(appstats_config["remote_servers"])
  ActiveRecord::Base.connection.disconnect!
end