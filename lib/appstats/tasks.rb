require 'rake'
require 'rake/tasklib'
require 'logger'

class AppstatsTasks < ::Rake::TaskLib
  attr_accessor :name, :base, :vendor, :config, :schema, :env, :default_env, :verbose, :log_level
  attr_reader :migrations
  
  def initialize(name = :appstats)
    @name = name
    base = File.expand_path('.')
    here = File.expand_path(File.dirname(File.dirname(File.dirname((__FILE__)))))
    @base = base
    @vendor = "#{here}/vendor"
    @my_migrations = "#{here}/db/migrations"
    @migrations = "#{base}/db/migrations"
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
  
  # def migrations=(*value)
  #   @migrations = value.flatten
  # end
  
  def define
    namespace :appstats do
      
      desc "Install or upgrade"
      task :install do
        puts "#{File.dirname((__FILE__))}"
        unless File.exists?(migrations)
          puts "Creating #{migrations} directory"
          mkdir migrations
        end
        puts "Moving migrations files from #{@my_migrations} into #{migrations}"
        system "cp -R #{@my_migrations}/* #{migrations}"
      end
      
    end
  end

  

end