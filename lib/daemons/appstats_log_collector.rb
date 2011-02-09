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

appstats_config = YAML::load(File.open(options[:config]))
ActiveRecord::Base.establish_connection(appstats_config['database'])
require File.join(File.dirname(__FILE__),"..","appstats")

Appstats.log(:info,"Started Appstats Log Collector")
while($running) do
  ActiveRecord::Base.connection.reconnect!
  appstats_config["remote_servers"].each do |remote_server|
    Appstats::LogCollector.find_remote_files(remote_server,remote_server[:path],remote_server[:template])
  end
  Appstats::LogCollector.download_remote_files(appstats_config["remote_servers"])
  Appstats::LogCollector.process_local_files
  ActiveRecord::Base.connection.disconnect!
  a_day_in_seconds = 60*60*24
  sleep a_day_in_seconds
end