require 'rubygems'
require 'active_record'
require "#{File.dirname(__FILE__)}/appstats/code_injections"
require "#{File.dirname(__FILE__)}/appstats/entry"
require "#{File.dirname(__FILE__)}/appstats/context"
require "#{File.dirname(__FILE__)}/appstats/tasks"
require "#{File.dirname(__FILE__)}/appstats/logger"
require "#{File.dirname(__FILE__)}/appstats/log_collector"

# required in the appstats.gemspec
# require "#{File.dirname(__FILE__)}/appstats/version"

module Appstats

  def self.log(type,message)
    if $logger.nil?
      # puts "LOCAL LOG #{type}: #{message}"
    else
      $logger.send(type,message)  
    end
  end
  
end
