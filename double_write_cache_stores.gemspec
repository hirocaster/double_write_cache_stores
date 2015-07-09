# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'double_write_cache_stores/version'

Gem::Specification.new do |spec|
  spec.name          = "double_write_cache_stores"
  spec.version       = DoubleWriteCacheStores::VERSION
  spec.authors       = ["hirocaster"]
  spec.email         = ["hohtsuka@gmail.com"]
  spec.summary       = %q{ Double write cache stores wrapper. }
  spec.description   = %q{ pre-warning(double write to cach store and other cache store) cache store wrapper. will switch cache store. }
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "activesupport", "= 3.2.15"
  spec.add_development_dependency "dalli", "= 2.7.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "padrino", "0.10.7"
  spec.add_development_dependency "tilt", "1.3.7"
end
