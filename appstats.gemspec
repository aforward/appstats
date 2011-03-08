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

  # Models are to be used in Rails 3 environment, but the logger can work with Rails 2 apps
  # But, for testing appstats itself, you will need Rails 3
  s.add_dependency('rails','>=2.3.0')
  s.add_dependency('daemons')
  s.add_dependency('net-scp')
  
  s.add_development_dependency('rspec')
  s.add_development_dependency('ZenTest')
  s.add_development_dependency('standalone_migrations')
  s.add_development_dependency('mysql')
  s.add_development_dependency('metric_fu')
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
