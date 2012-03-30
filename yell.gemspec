# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "yell/version"

Gem::Specification.new do |s|
  s.name        = "yell"
  s.version     = Yell::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Rudolf Schmidt"]

  s.homepage    = "http://rubygems.org/gems/yell"
  s.summary     = %q{Yell - Your Extensible Logging Library }
  s.description = %q{Yell - Your Extensible Logging Library. Define multiple adapters, various log level combinations or message formatting options like you've never done before}

  s.rubyforge_project = "yell"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rr"
end
