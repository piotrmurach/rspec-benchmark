# encoding: utf-8

module RSpec
  module Benchmark
    module ComparisonMatcher
      # Implements the `perform_faster_than` and `perform_slower_than` matchers
      #
      # @api private
      # @author WildDima
      class Matcher
        attr_reader :sample, :amount, :iterations, :sample_iterations, :comparison_type

        def initialize(sample, comparison_type, options = {})
          @sample = sample
          @comparison_type = comparison_type
        end

        # Indicates this matcher matches against a block
        #
        # @return [True]
        #
        # @api private
        def supports_block_expectations?
          true
        end

        # @return [Boolean]
        #
        # @api private
        def matches?(block)
          @amount ||= 1

          @sample_iterations = ips_for(sample)
          @iterations = ips_for(block)

          compare?
        end

        def in(amount)
          @amount = amount
          self
        end

        def times
          self
        end

        def failure_message
          "expected block to #{description}, but #{failure_reason}"
        end

        def failure_message_when_negated
          "expected block not to #{description}, but #{failure_reason}"
        end

        def description
          if amount == 1
            "perform #{comparison_type} than passed block"
          else
            "perform #{comparison_type} than passed block in #{@amount} times"
          end
        end

        def failure_reason
          if actual < 1
            "performed slower in #{format('%.2f', (actual**-1))} times"
          elsif actual > 1
            "performed faster in #{format('%.2f', actual)} times"
          else
            "performed by the same time"
          end
        end

        private

        def compare?
          case comparison_type
          when :faster
            iterations/amount > sample_iterations
          when :slower
            iterations/amount < sample_iterations
          else
            raise ArgumentError,
                  "comparison_type must be ':faster' or ':slower', not :'#{comparison_type}'"
          end
        end

        def actual
          iterations/sample_iterations.to_f
        end

        def ips_for(block)
          bench = ::Benchmark::Perf::Iteration.new
          average, stddev, _ = bench.run(&block)
          average + 3 * stddev
        end
      end
    end
  end
end