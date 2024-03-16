source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gemspec

# gem "benchmark-perf", github: "piotrmurach/benchmark-perf"
# gem "benchmark-trend", github: "piotrmurach/benchmark-trend"
# gem "benchmark-malloc", github: "piotrmurach/benchmark-malloc"

group :examples do
  gem "activerecord"
  gem "sqlite3", platforms: :mri
  gem "fast_jsonapi"
end

group :test do
  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.7.0")
    gem "coveralls_reborn", "~> 0.28.0"
    gem "simplecov", "~> 0.22.0"
  end
  gem "yardstick", "~> 0.9.9"
end
