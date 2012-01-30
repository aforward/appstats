require 'bundler'
Bundler::GemHelper.install_tasks

if ENV['RAILS_BUNDLE_FIRST']
  unless system('bundle check')
    # system('ruby -r rubygems -e "p Gem.path"')
    puts "RAILS_BUNDLE_FIRST is set, running `bundle install`..."
    system("bundle install") || raise("'bundle install' failed.")
  end
end

require 'appstats/tasks'
require 'metric_fu'
require 'rspec/core/rake_task'
require 'tasks/standalone_migrations'

import 'lib/appstats/ci.rake'

begin
  require 'tasks/standalone_migrations'
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
