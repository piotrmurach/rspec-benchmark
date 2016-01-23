# encoding: utf-8

require 'rspec/benchmark/timing_matcher'
require 'rspec/benchmark/iteration_matcher'

module RSpec
  module Benchmark
    module Matchers
      def perform_at_least(iterations, options = {})
        IterationMatcher::Matcher.new(iterations, options)
      end

      def perform_under(threshold, options = {})
        TimingMatcher::Matcher.new(threshold, options)
      end
    end # Matchers
  end # Benchmark
end # RSpec
