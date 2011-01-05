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

  s.rubyforge_project = "appstats"
  # s.add_dependency('hoe', '>= 2.1.0')
  # s.add_dependency('newgem')
  s.add_dependency('activerecord')
  
  s.add_development_dependency('rspec')


  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
