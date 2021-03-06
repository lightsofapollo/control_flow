# -*- encoding: utf-8 -*-
require File.expand_path('../lib/control_flow/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = 'control_flow'
  gem.version     = ControlFlow::VERSION
  gem.author      = "Lights of Apollo, LLC"
  gem.email       = 'gems@lightsofapollo.com'
  gem.homepage    = 'http://www.lightsofapollo.com'
  gem.summary     = %q{Control Flow library for abstract out user flow steps from controllers and other objects}
  gem.description = %q{Control Flow library for abstract out user flow steps from controllers and other objects}

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  gem.require_paths = ['lib']

  # gem.add_dependency('il8n')
  gem.add_dependency('activesupport', '>= 3.0.0')

  gem.add_development_dependency 'ZenTest', '~> 4.5'
  gem.add_development_dependency 'maruku', '~> 0.6'
  gem.add_development_dependency 'rake', '~> 0.9'
  gem.add_development_dependency 'rspec', '~> 2.6'
  gem.add_development_dependency 'simplecov', '~> 0.4'
  gem.add_development_dependency 'yard', '~> 0.7'
  gem.add_development_dependency 'watchr', '~> 0.7'  
end
