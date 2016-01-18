# RSpec::Benchmark
[![Gem Version](https://badge.fury.io/rb/rspec-benchmark.svg)][gem]
[![Build Status](https://secure.travis-ci.org/peter-murach/rspec-benchmark.svg?branch=master)][travis]
[![Code Climate](https://codeclimate.com/github/peter-murach/rspec-benchmark/badges/gpa.svg)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/peter-murach/rspec-benchmark/badge.svg)][coverage]
[![Inline docs](http://inch-ci.org/github/peter-murach/rspec-benchmark.svg?branch=master)][inchpages]

[gem]: http://badge.fury.io/rb/rspec-benchmark
[travis]: http://travis-ci.org/peter-murach/rspec-benchmark
[codeclimate]: https://codeclimate.com/github/peter-murach/rspec-benchmark
[coverage]: https://coveralls.io/r/peter-murach/rspec-benchmark
[inchpages]: http://inch-ci.org/github/peter-murach/rspec-benchmark

> Performance testing matchers for RSpec

## Why?

Integration and unit tests will ensure that changing code will maintain expected functionality. What is not guaranteed is the code changes impact on library performance. It is easy to refactor your way from fast to slow code.

If you are new to performance testing you may find [Caveats](caveats) section helpful.

## Contents

* [1. Usage](#1-usage)
* [2. Filtering](#2-filtering)
* [3. Caveats](#3-caveats)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec-benchmark'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-benchmark

## 1. Usage

### 1.1 TimingMatcher

This matcher answers the question of how long does it take to perform the given block of code on average. The measurements are taken executing the block of code in a child process for accurent cpu times.

To use the matcher, in your `spec_helper` do

```ruby
require 'rspec/benchmark/timinig_matcher'

RSpec.configure do |config|
  config.include(RSpec::Benchmark::TimingMatcher)
end
```

Then in your specs you can use `perform_below` matcher:

```ruby
expect { ... }.to perform_below(0.01)
```

by default the above code will be sampled `30` times but you can change this by using `and_sample` matcher:

```ruby
expect { ... }.to perform_below(0.01).and_sample(100)
```

### 1.2 IterationMatcher

The matcher allows you to establish performance benchmark of how many iterations per second a given block of code can be performed.

In your `spec_helper` do

```ruby
require 'rspec/benchmark/iteration_matcher'

RSpec.configure do |config|
  config.include(RSpec::Benchmark::IterationMatcher)
end
```

Then in your specs you can use `perform_at_least` matcher, for example, for a given block of code we expect at least 10K iterations per second:

```ruby
expect { ... }.to perform_at_least(10000).ips
```

## 2 Filtering

Usually performance tests are best left for CI or occasional runs that do not affect TDD/BDD cycle. To achieve isolation you can use RSpec filters. In your `spec_helper` do

```
config.filter_run_excluding performance: true
```

and then in your example group do:

```ruby
RSpec.describe ..., performance: true do
  ...
end
```

Another option is to simply isolate the performance specs in separate directory.

## 3 Caveats

When writing performance tests things to be mindful are:

+ The tests may **potentially be flaky** thus its best to use sensible boundaries:
  - **too strict** boundaries may cause false positives, making tests fail
  - **too relaxed** boundaries may also lead to false positives missing actual performance regressions
+ Generally performance tests will be **slow**, but you may try to avoid _unnecessarily_ slow tests by choosing smaller maximum value for sampling

If you have any other observations please share them!

## Contributing

1. Fork it ( https://github.com/peter-murach/rspec-benchmark/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Copyright

Copyright (c) 2016 Piotr Murach. See LICENSE for further details.
