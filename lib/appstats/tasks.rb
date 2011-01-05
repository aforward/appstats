require 'rake'
require 'rake/tasklib'
require 'logger'

class AppstatsTasks < ::Rake::TaskLib
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
      
      desc "Install or upgrade this gem (adds migration files, etc)"
      task :install do
        puts "#{File.dirname((__FILE__))}"
        unless File.exists?(migrations)
          puts "Creating migrate directory\n  #{@app_migrate}"
          mkdir @app_migrate
        end
        puts "Moving migrations files from:\n   #{@gem_migrations}\nTo\n   #{@app_migrate}"
        system "cp -R #{@gem_migrations}/* #{@app_migrate}"
      end
      
    end
  end

end

AppstatsTasks.new