# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bumpy_bridge/version'

Gem::Specification.new do |spec|
  spec.name          = "bumpy_bridge"
  spec.version       = BumpyBridge::VERSION
  spec.authors       = ["phil"]
  spec.email         = ["phil@branch14.org"]
  spec.description   = %q{Bridging RabbitMQ and Faye.}
  spec.summary       = %q{Bridging RabbitMQ and Faye.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency "faye"
  spec.add_dependency 'faye-authentication'
  spec.add_dependency "bunny"
  spec.add_dependency "daemons"
  spec.add_dependency "trickery"

end
