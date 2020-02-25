require_relative "lib/rspec/benchmark/version"

Gem::Specification.new do |spec|
  spec.name          = "rspec-benchmark"
  spec.version       = RSpec::Benchmark::VERSION
  spec.authors       = ["Piotr Murach"]
  spec.email         = ["piotr@piotrmurach.com"]
  spec.summary       = %q{Performance testing matchers for RSpec}
  spec.description   = %q{Performance testing matchers for RSpec to set expectations on speed, resources usage and scalibility.}
  spec.homepage      = "https://github.com/piotrmurach/rspec-benchmark"
  spec.license       = "MIT"
  if spec.respond_to?(:metadata)
    spec.metadata["bug_tracker_uri"] = "https://github.com/piotrmurach/rspec-benchmark/issues"
    spec.metadata["changelog_uri"] = "https://github.com/piotrmurach/rspec-benchmark/blob/master/CHANGELOG.md"
    spec.metadata["documentation_uri"] = "https://www.rubydoc.info/gems/rspec-benchmark"
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/piotrmurach/rspec-benchmark"
  end
  spec.files         = Dir["lib/**/*"]
  spec.extra_rdoc_files = Dir["README.md", "CHANGELOG.md", "LICENSE.txt"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.1.0"

  spec.add_dependency "benchmark-malloc", "~> 0.1.0"
  # spec.add_dependency "benchmark-perf",   "~> 0.6.0"
  spec.add_dependency "benchmark-trend",  "~> 0.3.0"
  spec.add_dependency "rspec", ">= 3.0.0", "< 4.0.0"

  spec.add_development_dependency "rake", "~> 10.0"
end
