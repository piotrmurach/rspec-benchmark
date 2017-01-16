# encoding: utf-8

module RSpec
  module Benchmark
    module CompareMatcher
      class FasterThanMatcher
        attr_reader :sample, :amount, :iterations, :sample_iterations

        def initialize(sample, options = {})
          @sample = sample
        end

        def supports_block_expectations?
          true
        end

        def matches?(block)
          @amount ||= 1

          @sample_iterations = ips_for(sample)
          @iterations = ips_for(block)

          iterations/amount > sample_iterations
        end

        def in(amount)
          @amount = amount
          self
        end

        def times
          self
        end

        def failure_message
          "expected block to #{description}, but #{positive_failure_reason}"
        end

        def failure_message_when_negated
          "expected block not to #{description}, but #{negative_failure_reason}"
        end

        def description
          if amount == 1
            "perform faster than passed block"
          else
            "perform faster than passed block in #{@amount} times"
          end
        end

        def actual
          iterations/sample_iterations
        end

        def positive_failure_reason
          "performed slower in #{actual} times"
        end

        def negative_failure_reason
          "performed faster in #{actual} times"
        end

        private

        def ips_for(block)
          bench = ::Benchmark::Perf::Iteration.new
          average, stddev, _ = bench.run(&block)
          average + 3 * stddev
        end
      end
    end
  end
end