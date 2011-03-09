require 'bundler'
Bundler::GemHelper.install_tasks

require 'appstats/tasks'
require 'metric_fu'
require 'rspec/core/rake_task'
require 'tasks/standalone_migrations'

import 'lib/appstats/ci.rake'

begin
  MigratorTasks.new do |t|
    t.migrations = "db/migrations"
    t.config = "db/config.yml"
    t.schema = "db/schema.rb"
    t.env = "DB"
    t.default_env = "development"
    t.verbose = true
    t.log_level = Logger::ERROR
  end
rescue LoadError => e
  puts "gem install standalone_migrations to get db:migrate:* tasks! (Error: #{e})"
end

RSpec::Core::RakeTask.new(:spec) do |t|
	t.pattern = "spec/*_spec.rb"
	t.rspec_opts = "--color"
end

MetricFu::Configuration.run do |config|
  config.metrics = [:rcov]
  config.rcov[:test_files] = ['spec/*_spec.rb']
  config.rcov[:rcov_opts] << '-Ispec'
end
