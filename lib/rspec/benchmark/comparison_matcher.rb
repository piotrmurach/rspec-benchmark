# frozen_string_literal: true

require "benchmark-perf"

module RSpec
  module Benchmark
    module ComparisonMatcher
      # Implements the `perform_faster_than` and `perform_slower_than` matchers
      #
      # @api private
      class Matcher
        DEFAULT_EXPECTED_COUNT_MATCHERS = { at_least: 1 }.freeze

        def initialize(expected, comparison_type, **options)
          check_comparison(comparison_type)
          @expected = expected
          @comparison_type = comparison_type
          @count      = 1
          @time       = options.fetch(:time) { 0.2 }
          @warmup     = options.fetch(:warmup) { 0.1 }
          @bench      = ::Benchmark::Perf::Iteration
          @expected_count_matchers = {}
        end

        # Indicates this matcher matches against a block
        #
        # @return [True]
        #
        # @api private
        def supports_block_expectations?
          true
        end

        def matcher_name
          "perform_#{@comparison_type}_than"
        end

        # @return [Boolean]
        #
        # @api private
        def matches?(block)
          @actual = block
          return false unless @actual.is_a?(Proc)

          @expected_ips, @expected_stdev, = @bench.run(time: @time, warmup: @warmup, &@expected)
          @actual_ips, @actual_stdev, = @bench.run(time: @time, warmup: @warmup, &@actual)

          @ratio = @actual_ips / @expected_ips.to_f

          expected_count_matchers.all? { |type, count| matches_comparison?(type, count) }
        end

        # The time before measurements are taken
        #
        # @param [Numeric] value
        #   the time before measurements are taken
        #
        # @api public
        def warmup(value)
          @warmup = value
          self
        end

        # Time to measure iteration for
        #
        # @param [Numeric] value
        #   the time to take measurements for
        #
        # @api public
        def within(value)
          @time = value
          self
        end

        # Specify the minimum number of times a block
        # is faster/slower than other.
        # @api public
        def at_least(n)
          set_expected_times_count(:at_least, n)
          self
        end

        # Specify the maximum number of times a block
        # is faster/slower than another.
        # @api public
        def at_most(n)
          set_expected_times_count(:at_most, n)
          self
        end

        # Specify exact number of times a block
        # is faster/slower than another.
        # @api public
        def exactly(n)
          set_expected_times_count(:exactly, n)
          self
        end

        # Specify that the code runs faster/slower exactly once.
        # @api public
        def once
          exactly(1)
          self
        end

        # Specify that the code runs faster/slower exactly twice.
        def twice
          exactly(2)
          self
        end

        # Specify that the code runs faster/slower exactly thrice.
        # @api public
        def thrice
          exactly(3)
          self
        end

        # No-op, syntactic sugar.
        # @api public
        def times
          self
        end

        # @api private
        def failure_message
          "expected given block to #{description}, but #{failure_reason}"
        end

        # @api private
        def failure_message_when_negated
          "expected given block not to #{description}, but #{failure_reason}"
        end

        # @api private
        def description
          main_description = "perform #{@comparison_type} than comparison block"
          description_extra = comparison_description
          return main_description if !description_extra || description_extra.empty?

          [main_description, comparison_description].compact.join(' ')
        end

        # @api private
        def failure_reason
          return "was not a block" unless @actual.is_a?(Proc)

          if @ratio < 1
            "performed slower by #{format("%.2f", (@ratio**-1))} times"
          elsif @ratio > 1
            "performed faster by #{format("%.2f", @ratio)} times"
          else
            "performed by the same time"
          end
        end

        private

        def comparison_description
          expected_count_matchers
            .select { |_, count| count != 1 }
            .map { |type, count| "by #{type} #{count} times" }
            .join(' and ')
        end

        def convert_count(n)
          case n
          when Numeric then n
          when :once then 1
          when :twice then 2
          when :thrice then 3
          else
            raise "The #{matcher_name} matcher is not designed to be used " \
                  "with #{n} count type."
          end
        end

        def set_expected_times_count(type, n)
          @expected_count_matchers ||= {}
          @expected_count_matchers[type] = convert_count(n)
        end

        def expected_count_matchers
          @expected_count_matchers.empty? ? DEFAULT_EXPECTED_COUNT_MATCHERS : @expected_count_matchers
        end

        def matches_comparison?(count_type, count)
          case count_type
          when :at_most
            at_most_comparison(count)
          when :exactly
            exact_comparison(count)
          else
            default_comparison(count)
          end
        end

        # At most comparison
        #
        # @example
        #   @ratio = 3
        #   @count = 4
        #   perform_faster_than { ... }.at_most(@count).times # => true
        #
        #   @ratio = 3
        #   @count = 2
        #   perform_faster_than { ... }.at_most(@count).times # => false
        #
        #   @ratio = 1/4
        #   @count = 5
        #   perform_slower_than { ... }.at_most(@count).times # => true
        #
        #   @ratio = 1/4
        #   @count = 3
        #   perform_slower_than { ... }.at_most(@count).times # => false
        #
        # @return [Boolean]
        #
        # @api private
        def at_most_comparison(count)
          if @comparison_type == :faster
            1 < @ratio && @ratio < count
          else
            count**-1 < @ratio && @ratio < 1
          end
        end

        # Check if expected ips is faster/slower than actual ips
        # exactly number of counts.
        #
        # @example
        #   @ratio = 3.5
        #   @count = 3
        #   perform_faster_than { ... }.exact(@count).times # => true
        #
        #   @ratio = 1/4
        #   @count = 4
        #   perform_slower_than { ... }.exact(@count).times # => true
        #
        # @return [Boolean]
        #
        # @api private
        def exact_comparison(count)
          if @comparison_type == :faster
            count == @ratio.round
          else
            count == (1.0 / @ratio).round
          end
        end

        # At least comparison, meaning more than expected count
        #
        # @example
        #   @ratio = 4
        #   @count = 3
        #   perform_faster_than { ... } # => true
        #
        #   @ratio = 4
        #   @count = 3
        #   perform_faster_than { ... }.at_least(@count).times # => true
        #
        #   @ratio = 1/4
        #   @count = 3
        #   perform_slower_than { ... }.at_least(@count).times # => false
        #
        #   @ratio = 1/3
        #   @count = 4
        #   perform_slower_than { ... }.at_least(@count).times # => true
        #
        # @return [Boolean]
        #
        # @api private
        def default_comparison(count)
          if @comparison_type == :faster
            @ratio > count
          else
            @ratio < (1.0 / count)
          end
        end

        def check_comparison(type)
          [:slower, :faster].include?(type) ||
            (raise ArgumentError, "comparison_type must be " \
                   ":faster or :slower, not `:#{type}`")
        end
      end # Matcher
    end # ComparisonMatcher
  end # Benchmark
end # RSpec
