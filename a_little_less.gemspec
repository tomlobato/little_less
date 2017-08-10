# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'a_little_less/version'

Gem::Specification.new do |spec|
  spec.name          = "a_little_less"
  spec.version       = ALittleLess::VERSION
  spec.authors       = ["Tom Lobato"]

  spec.summary       = 'Basic web framework in Ruby'
  spec.description   = 'Basic web framework in Ruby.'
  spec.homepage      = "https://tomlobato.github.io/a_little_less"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"

  spec.add_runtime_dependency 'rack', '~> 2.0'
  spec.add_runtime_dependency 'i18n', '~> 0.7'
  spec.add_runtime_dependency 'colorize', '~> 0.8'
  spec.add_runtime_dependency 'activerecord', '~> 5.0.2'
  spec.add_runtime_dependency 'bugsnag', '~> 5.0'
end

