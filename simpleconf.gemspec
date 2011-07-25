# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "simpleconf/version"

Gem::Specification.new do |s|
  s.name        = "simpleconf"
  s.version     = SimpleConf::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Mike Lewis"]
  s.email       = ["ft.mikelewis@gmail.com"]
  s.homepage    = "http://github.com/mikelewis/simpleconf"
  s.summary     = %q{Simple Configuration DSL that supports merging, locking and more.}
  s.description = %q{Simple Configuration DSL that supports merging, locking and more.}

  s.rubyforge_project = "simpleconf"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'blankslate'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
end
