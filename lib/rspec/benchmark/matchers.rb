# encoding: utf-8

require 'rspec/benchmark/timing_matcher'
require 'rspec/benchmark/iteration_matcher'
require 'rspec/benchmark/comparison_matcher'

module RSpec
  module Benchmark
    # Provides a number of useful performance testing expectations
    #
    # These matchers can be exposed by including the this module in
    # a spec:
    #
    #   RSpec.describe "Performance testing" do
    #     include RSpec::Benchmark::Matchers
    #   end
    #
    # or you can include in globablly in a spec_helper.rb file:
    #
    #   RSpec.configure do |config|
    #     config.inlucde(RSpec::Benchmark::Matchers)
    #   end
    #
    # @api public
    module Matchers
      # Passes if code block performs at least iterations
      #
      # @param [Integer] iterations
      #
      # @example
      #   expect { ... }.to perform_at_least(10000)
      #   expect { ... }.to perform_at_least(10000).ips
      #
      # @api public
      def perform_at_least(iterations, **options)
        IterationMatcher::Matcher.new(iterations, options)
      end

      # Passes if code block performs under threshold
      #
      # @param [Float] threshold
      #
      # @example
      #   expect { ... }.to peform_under(0.001)
      #   expect { ... }.to peform_under(0.001).sec
      #   expect { ... }.to peform_under(10).ms
      #
      # @api public
      def perform_under(threshold, **options)
        TimingMatcher::Matcher.new(threshold, options)
      end

      # Passes if code block performs faster than sample block
      #
      # @param [Proc] sample
      #
      # @example
      #   expect { ... }.to peform_faster_than { ... }
      #   expect { ... }.to peform_faster_than { ... }.at_least(5).times
      #
      # @api public
      def perform_faster_than(**options, &sample)
        ComparisonMatcher::Matcher.new(sample, :faster, options)
      end

      # Passes if code block performs slower than sample block
      #
      # @param [Proc] sample
      #
      # @example
      #   expect { ... }.to peform_slower_than { ... }
      #   expect { ... }.to peform_slower_than { ... }.at_most(5).times
      #
      # @api public
      def perform_slower_than(**options, &sample)
        ComparisonMatcher::Matcher.new(sample, :slower, options)
      end
    end # Matchers
  end # Benchmark
end # RSpec
