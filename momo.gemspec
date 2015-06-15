# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'momo/version'

Gem::Specification.new do |spec|
  spec.name          = "momo"
  spec.version       = Momo::VERSION
  spec.authors       = ["David Siaw"]
  spec.email         = ["david.siaw@mobingi.com"]
  spec.summary       = %q{Mobingi Deployment System}
  spec.description   = %q{Deploys Cloud Servers}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "aws-sdk-core"
  spec.add_dependency "json"
  spec.add_dependency "trollop"


  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end

