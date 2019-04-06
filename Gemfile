source 'https://rubygems.org'

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gemspec

gem 'benchmark-perf', github: 'piotrmurach/benchmark-perf'
# gem 'benchmark-malloc', github: 'piotrmurach/benchmark-malloc'

gem 'activerecord'
gem 'sqlite3'
gem 'fast_jsonapi'

group :test do
  gem 'coveralls', '~> 0.8.22'
  gem 'simplecov', '~> 0.16.1'
  gem 'yardstick', '~> 0.9.9'
end
