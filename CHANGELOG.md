# Change log

## [v0.5.0] - 2019-04-06

## Added
* Add benchmark-malloc as a dependency
* Add AllocationMatcher with  #perform_allocation expectation
* Add #perform_log, #perform_exp aliases
* Add ability to configure error threshold when asserting computational complexity

## Changed
* Change CompexityMatcher to use threshold when verifying the assertion

## [v0.4.0] - 2018-10-01

### Added
* Add benchmark-trend as a dependency
* Add ComplexityMatcher with #perform_linear, #perform_constant,
  #perform_logarithmic, #perform_power and #perform_exponential expectations
* Add #within and #warmup matchers to IterationMatcher
* Add #warmup matcher to TimingMatcher
* Add #within and #warmup matchers to ComparisonMatcher

### Changed
* Change to require Ruby >= 2.0.0
* Change to update benchmark-perf dependency
* Change IterationMatcher to use new Benchmark::Perf::Iteration api
* Change TimingMatcher to use new Benchmark::Perf::ExecutionTime api
* Change ComparisonMatcher to use new Benchmark::Perf::Iteration api
* Change #and_sample matcher to #sample
* Change TimingMatcher to run only one sample by default

## [v0.3.0] - 2017-02-05

### Added
* Add ComparisonMatcher with #perform_faster_than and #perform_slower_than expectations by Dmitri(@WildDima)
* Add ability to configure timing options for all Matchers such as :warmup & :time

## [v0.2.0] - 2016-11-01

### Changed
* Update dependency for benchmark-perf

## [v0.1.0] - 2016-01-25

Initial release

[v0.5.0]: https://github.com/peter-murach/rspec-benchmark/compare/v0.4.0...v0.5.0
[v0.4.0]: https://github.com/peter-murach/rspec-benchmark/compare/v0.3.0...v0.4.0
[v0.3.0]: https://github.com/peter-murach/rspec-benchmark/compare/v0.2.0...v0.3.0
[v0.2.0]: https://github.com/peter-murach/rspec-benchmark/compare/v0.1.0...v0.2.0
[v0.1.0]: https://github.com/peter-murach/rspec-benchmark/compare/v0.1.0
