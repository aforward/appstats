require 'rubygems'
require 'active_record'
require 'rails' unless Object.const_defined?('Rails')

require "#{File.dirname(__FILE__)}/appstats/acts_as_appstatsable"
require "#{File.dirname(__FILE__)}/appstats/acts_as_auditable"
require "#{File.dirname(__FILE__)}/appstats/benchmarker"
require "#{File.dirname(__FILE__)}/appstats/inmemory_redis"
require "#{File.dirname(__FILE__)}/appstats/code_injections"
require "#{File.dirname(__FILE__)}/appstats/entry"
require "#{File.dirname(__FILE__)}/appstats/audit"
require "#{File.dirname(__FILE__)}/appstats/entry_date"
require "#{File.dirname(__FILE__)}/appstats/date_range"
require "#{File.dirname(__FILE__)}/appstats/action"
require "#{File.dirname(__FILE__)}/appstats/context"
require "#{File.dirname(__FILE__)}/appstats/action_context_key"
require "#{File.dirname(__FILE__)}/appstats/tasks"
require "#{File.dirname(__FILE__)}/appstats/logger"
require "#{File.dirname(__FILE__)}/appstats/log_collector"
require "#{File.dirname(__FILE__)}/appstats/parser"
require "#{File.dirname(__FILE__)}/appstats/query"
require "#{File.dirname(__FILE__)}/appstats/result"
require "#{File.dirname(__FILE__)}/appstats/sub_result"
require "#{File.dirname(__FILE__)}/appstats/result_job"
require "#{File.dirname(__FILE__)}/appstats/host"
require "#{File.dirname(__FILE__)}/appstats/friendly_timer"
require "#{File.dirname(__FILE__)}/appstats/context_key"
require "#{File.dirname(__FILE__)}/appstats/appstats_query"
require "#{File.dirname(__FILE__)}/appstats/context_value"
require "#{File.dirname(__FILE__)}/appstats/test_object"
require "#{File.dirname(__FILE__)}/appstats/test_query"

# required in the appstats.gemspec
unless Appstats.const_defined?(:VERSION)
  require "#{File.dirname(__FILE__)}/appstats/version"
end

module Appstats

  def self.log(type,raw_message)
    message = "VERSION #{Appstats::VERSION} : #{raw_message}"
    if !$logger.nil?
      $logger.send(type,message)
    elsif defined?(Rails)
      Rails.logger.send(type,message) unless Rails.logger.nil?
    elsif defined?(RAILS_DEFAULT_LOGGER)
      RAILS_DEFAULT_LOGGER.send(type,message)
    else
      # puts "LOCAL LOG #{type}: #{message}"
    end
  end
  
  def self.rails3?
    Appstats::Action.respond_to?(:where)
  end
  
  def self.connection
    Appstats::Entry.new.connection
  end
  
end
