require 'rubygems'
require 'active_record'
require "#{File.dirname(__FILE__)}/appstats/acts_as_appstatsable"
require "#{File.dirname(__FILE__)}/appstats/code_injections"
require "#{File.dirname(__FILE__)}/appstats/entry"
require "#{File.dirname(__FILE__)}/appstats/entry_date"
require "#{File.dirname(__FILE__)}/appstats/date_range"
require "#{File.dirname(__FILE__)}/appstats/action"
require "#{File.dirname(__FILE__)}/appstats/context"
require "#{File.dirname(__FILE__)}/appstats/tasks"
require "#{File.dirname(__FILE__)}/appstats/logger"
require "#{File.dirname(__FILE__)}/appstats/log_collector"
require "#{File.dirname(__FILE__)}/appstats/query"
require "#{File.dirname(__FILE__)}/appstats/result"
require "#{File.dirname(__FILE__)}/appstats/host"
require "#{File.dirname(__FILE__)}/appstats/parser"
require "#{File.dirname(__FILE__)}/appstats/test_object"

# required in the appstats.gemspec
unless Appstats.const_defined?(:VERSION)
  require "#{File.dirname(__FILE__)}/appstats/version"
end

module Appstats

  def self.log(type,message)
    if $logger.nil?
      # puts "LOCAL LOG #{type}: #{message}"
    else
      $logger.send(type,message)  
    end
  end
  
end
