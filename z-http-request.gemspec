# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'z-http/version'

Gem::Specification.new do |s|
  s.name        = 'z-http-request'
  s.version     = ZMachine::HttpRequest::VERSION

  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ilya Grigorik", "LiquidM, Inc."]
  s.email       = ['ilya@igvita.com', "opensource@liquidm.com"]
  s.homepage    = 'http://github.com/liquidm/z-http-request'
  s.summary     = 'ZMachine based, async HTTP Request client'
  s.description = s.summary
  s.license     = 'MIT'
  s.rubyforge_project = 'z-http-request'

  s.add_dependency 'addressable', '>= 2.3.4'
  s.add_dependency 'cookiejar'
  s.add_dependency 'zmachine'
  s.add_dependency 'http_parser.rb', '>= 0.6.0.beta.2'

  s.add_development_dependency 'puma'
  s.add_development_dependency 'multi_json'
  s.add_development_dependency 'rack'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end
