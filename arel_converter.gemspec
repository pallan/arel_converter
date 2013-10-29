# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'arel_converter/version'

Gem::Specification.new do |spec|
  spec.name          = "arel_converter"
  spec.version       = ArelConverter::VERSION
  spec.authors       = ["Peer Allan"]
  spec.email         = ["peer.allan@canadadrugs.com"]
  spec.description   = %q{Converts existing AR finder syntax to AREL}
  spec.summary       = %q{Converts AR finders, scopes and association arguments to AREL syntax}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency('ruby2ruby')
  spec.add_dependency('ruby_parser')
  spec.add_dependency('logging')

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
