require 'rake'
require 'rake/tasklib'
require 'logger'

module Appstats
  def self.table_name() "mice" end
  
  class Tasks < ::Rake::TaskLib
    attr_accessor :name, :base, :vendor, :config, :schema, :env, :default_env, :verbose, :log_level
  
    def initialize(name = :appstats)
      @name = name
      base = File.expand_path('.')
      here = File.expand_path(File.dirname(File.dirname(File.dirname((__FILE__)))))
      @base = base
      @vendor = "#{here}/vendor"
      @gem_migrations = "#{here}/db/migrations"
      @app_migrate = "#{base}/db/migrate"
      @config = "#{base}/db/config.yml"
      @schema = "#{base}/db/schema.rb"
      @appstats_initializer = "#{base}/config/initializers/appstats_config.rb"
      @appstats_initializer_template = "#{here}/lib/templates/appstats_config.rb"
      @env = 'DB'
      @default_env = 'development'
      @verbose = true
      @log_level = Logger::ERROR
      yield self if block_given?
      # Add to load_path every "lib/" directory in vendor
      Dir["#{vendor}/**/lib"].each{|p| $LOAD_PATH << p }
      define
    end
  
    def define
      namespace :appstats do
        namespace :install do
          desc "Install the migrations for this gem (for the database aspect of the gem)"
          task :migrations do
            unless File.exists?(@app_migrate)
              puts "Creating migrate directory"
              mkdir @app_migrate
            end
            puts "Moving migrations files from:\n> #{@gem_migrations}\nTo\n> #{@app_migrate}"
            system "cp -R #{@gem_migrations}/* #{@app_migrate}"
          end
          
          desc "Install the logger for this gem (for application instances that log statistics)"
          task :logger do
            if File.exists?(@appstats_initializer)
              puts "Initialize [#{@appstats_initializer}] already exists, creating example file [#{@appstats_initializer}.example] to see any new changes since you last installed this gem"
              system "cp -R #{@appstats_initializer_template} #{@appstats_initializer}.example"
            else
              puts "Creating default initializer [#{@appstats_initializer}]"
              system "cp -R #{@appstats_initializer_template} #{@appstats_initializer}"
            end
          end
        end
      end
    end
  end
end

Appstats::Tasks.new