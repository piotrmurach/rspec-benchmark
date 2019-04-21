lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/benchmark/version'

Gem::Specification.new do |spec|
  spec.name          = "rspec-benchmark"
  spec.version       = RSpec::Benchmark::VERSION
  spec.authors       = ["Piotr Murach"]
  spec.email         = ["me@piotrmurach.com"]
  spec.summary       = %q{Performance testing matchers for RSpec}
  spec.description   = %q{Performance testing matchers for RSpec to set expectations on speed, resources usage and scalibility.}
  spec.homepage      = "https://github.com/piotrmurach/rspec-benchmark"
  spec.license       = "MIT"

  if spec.respond_to?(:metadata)
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/piotrmurach/rspec-benchmark"
    spec.metadata["changelog_uri"] = "https://github.com/piotrmurach/rspec-benchmark/blob/master/CHANGELOG.md"
  end

  spec.files         = Dir['{lib,spec}/**/*.rb']
  spec.files        += Dir['tasks/*', 'rspec-benchmark.gemspec']
  spec.files        += Dir['README.md', 'CHANGELOG.md', 'LICENSE.txt', 'Rakefile']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.1.0'

  spec.add_dependency 'benchmark-malloc', '~> 0.1.0'
  spec.add_dependency 'benchmark-perf',   '~> 0.5.0'
  spec.add_dependency 'benchmark-trend',  '~> 0.3.0'
  spec.add_dependency 'rspec', '>= 3.0.0', '< 4.0.0'

  spec.add_development_dependency 'bundler', '>= 1.5'
  spec.add_development_dependency 'rake'
end
