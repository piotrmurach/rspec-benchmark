# encoding: utf-8

module RSpec
  module Benchmark
    module ComparisonMatcher
      # Implements the `perform_faster_than` and `perform_slower_than` matchers
      #
      # @api private
      class Matcher
        def initialize(expected, comparison_type, **options)
          check_comparison(comparison_type)
          @expected = expected
          @comparison_type = comparison_type
          @count = 1
          @count_type = :at_least
          time   = options.fetch(:time) { 0.2 }
          warmup = options.fetch(:warmup) { 0.1 }
          @bench = ::Benchmark::Perf::Iteration.new(time: time, warmup: warmup)
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
          return false unless (Proc === @actual)

          @expected_ips, @expected_stdev, _ = @bench.run(&@expected)
          @actual_ips, @actual_stdev, _ = @bench.run(&@actual)

          case @count_type
          when :at_most
            at_most_comparison
          when :exactly
            exact_comparison
          else
            default_comparison
          end
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
          if @count == 1
            "perform #{@comparison_type} than comparison block"
          else
            "perform #{@comparison_type} than comparison block " \
            "by #{@count_type} #{@count} times"
          end
        end

        # @api private
        def failure_reason
          return "was not a block" unless (Proc === @actual)

          if actual < 1
            "performed slower by #{format('%.2f', (actual**-1))} times"
          elsif actual > 1
            "performed faster by #{format('%.2f', actual)} times"
          else
            "performed by the same time"
          end
        end

        private

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
          @count_type = type
          @count = convert_count(n)
        end

        # @return [Boolean]
        # @example
        #   @actual = 40
        #   @count = 41
        #   perform_faster_than { ... }.at_most(@count).times # => true
        #
        #   @actual = 40
        #   @count = 41
        #   perform_faster_than { ... }.at_most(@count).times # => false
        #
        #   @actual = 1/40
        #   @count = 41
        #   perform_slower_than { ... }.at_most(@count).times # => true
        #
        #   @actual = 1/40
        #   @count = 41
        #   perform_slower_than { ... }.at_most(@count).times # => false
        # @api private
        def at_most_comparison
          if @comparison_type == :faster
            1 < actual && actual < @count
          else
            actual < 1 && actual > 1 / @count.to_f
          end
        end

        # Check if expected ips is faster/slower than actual ips
        # exactly number of counts.
        #
        # @example
        #   @actual = 40.1
        #   @count = 40
        #   perform_faster_than { ... }.exact(@count).times # => true
        #
        #   @actual = 40.1
        #   @count = 41
        #   perform_faster_than { ... }.exact(@count).times # => true
        #
        # @return [Boolean]
        #
        # @api private
        def exact_comparison
          @count == actual.round
        end

        # @return [Boolean]
        # @example
        #   @actual = 41
        #   @count = 40
        #   perform_faster_than { ... } # => true
        #
        #   @actual = 41
        #   @count = 40
        #   perform_faster_than { ... }.at_least(@count).times # => true
        #
        #   @actual = 1/40
        #   @count = 41
        #   perform_slower_than { ... }.at_least(@count).times # => false
        #
        #   @actual = 1/41
        #   @count = 40
        #   perform_slower_than { ... }.at_least(@count).times # => true
        # @api private
        def default_comparison
          if @comparison_type == :faster
            actual / @count > 1
          else
            actual / @count < 1 / @count.to_f
          end
        end

        def check_comparison(type)
          [:slower, :faster].include?(type) ||
           (raise ArgumentError, "comparison_type must be " \
                  ":faster or :slower, not `:#{type}`")
        end

        def actual
          @actual_ips / @expected_ips.to_f
        end
      end
    end # ComparisonMatcher
  end # Benchmark
end # RSpec
