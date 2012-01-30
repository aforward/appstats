# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "appstats/version"

Gem::Specification.new do |s|
  s.name        = "appstats"
  s.version     = Appstats::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Andrew Forward"]
  s.email       = ["aforward@gmail.com"]
  s.homepage    = "http://github.com/aforward/appstats"
  s.summary     = %q{Provide usage statistics about how your application is being used}
  s.description = %q{Provide usage statistics about how your application is being used}

  s.add_dependency('rails','>=3.2.1')
  s.add_dependency('daemons')
  s.add_dependency('net-scp')
  s.add_dependency('redis')
  
  s.add_development_dependency('rake')
  s.add_development_dependency('rspec')
  s.add_development_dependency('ZenTest')
  s.add_development_dependency('standalone_migrations')
  s.add_development_dependency('mysql2')
  s.add_development_dependency('metric_fu')
  s.add_development_dependency('guard-rspec')
  s.add_development_dependency('autotest-fsevent') if RUBY_PLATFORM =~ /darwin/i
  s.add_development_dependency('rb-fsevent') if RUBY_PLATFORM =~ /darwin/i

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end