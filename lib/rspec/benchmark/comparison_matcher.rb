# encoding: utf-8

module RSpec
  module Benchmark
    module ComparisonMatcher
      # Implements the `perform_faster_than` and `perform_slower_than` matchers
      #
      # @api private
      class Matcher
        attr_reader :sample,
                    :amount,
                    :iterations,
                    :sample_iterations,
                    :comparison_type,
                    :threshold_type

        def initialize(sample, comparison_type, options = {})
          check_comparison(comparison_type)
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

          case threshold_type
          when :at_most
            at_most_comparison
          when :exactly
            exactly_comparison
          else
            default_comparison
          end
        end

        def at_least(amount)
          @amount = amount
          @threshold_type = :at_least
          self
        end

        def at_most(amount)
          @amount = amount
          @threshold_type = :at_most
          self
        end

        def exactly(amount)
          @amount = amount
          @threshold_type = :exactly
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
            "perform #{comparison_type} than passed block " \
            "#{threshold_type} in #{amount} times"
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

        # @return [Boolean]
        # @example
        #   @actual = 40
        #   @amount = 41
        #   perform_faster_than { ... }.at_most(@amount).times # => true
        #
        #   @actual = 40
        #   @amount = 41
        #   perform_faster_than { ... }.at_most(@amount).times # => false
        #
        #   @actual = 1/40
        #   @amount = 41
        #   perform_slower_than { ... }.at_most(@amount).times # => true
        #
        #   @actual = 1/40
        #   @amount = 41
        #   perform_slower_than { ... }.at_most(@amount).times # => false
        # @api private
        def at_most_comparison
          if comparison_type == :faster
            1 < actual && actual < amount
          else
            actual < 1 && actual > 1 / amount.to_f
          end
        end

        # @return [Boolean]
        # @example
        #   @actual = 40.1
        #   @amount = 40
        #   perform_faster_than { ... }.exactly(@amount).times # => true
        #
        #   @actual = 45
        #   @amount = 40
        #   perform_faster_than { ... }.exactly(@amount).times # => true
        #
        #   @actual = 55
        #   @amount = 40
        #   perform_faster_than { ... }.exactly(@amount).times # => false
        # @api private
        def exactly_comparison
          (amount - 0.3 .. amount + 0.3).include? actual
        end

        # @return [Boolean]
        # @example
        #   @actual = 41
        #   @amount = 40
        #   perform_faster_than { ... } # => true
        #
        #   @actual = 41
        #   @amount = 40
        #   perform_faster_than { ... }.at_least(@amount).times # => true
        #
        #   @actual = 1/40
        #   @amount = 41
        #   perform_slower_than { ... }.at_least(@amount).times # => false
        #
        #   @actual = 1/41
        #   @amount = 40
        #   perform_slower_than { ... }.at_least(@amount).times # => true
        # @api private
        def default_comparison
          if comparison_type == :faster
            actual / amount > 1
          else
            actual / amount < 1 / amount.to_f
          end
        end

        def check_comparison(type)
          [:slower, :faster].include?(type) ||
            (raise ArgumentError, "comparison_type must be " \
                  ":faster or :slower, not `:#{type}`")
        end

        def actual
          iterations / sample_iterations.to_f
        end

        def ips_for(block)
          bench = ::Benchmark::Perf::Iteration.new
          average, stddev, _ = bench.run(&block)
          average + 3 * stddev
        end
      end
    end # ComparisonMatcher
  end # Benchmark
end # RSpec
