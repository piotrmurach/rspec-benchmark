# encoding: utf-8

module RSpec
  module Benchmark
    module TimingMatcher
      # Implements the `perform_below` matcher
      #
      # @api private
      class Matcher
        def initialize(threshold, options = {})
          @threshold = threshold
          @samples = options.fetch(:samples) { 30 }
          @scale = threshold.to_s.split(/\./).last.size
          @block = nil
          @confidence_interval = nil
        end

        def supports_block_expectations?
          true
        end

        def matches?(block)
          @block = block
          return false unless block.is_a?(Proc)
          @bench = ::Benchmark::Performance.new
          @average, @stddev = @bench.run(@samples, &block)
          (@average - 3 * @stddev) <= @threshold
        end

        def does_not_match?(block)
          !matches?(block) && block.is_a?(Proc)
        end

        def and_sample(samples)
          @samples = samples
          self
        end

        def seconds
          self
        end

        def failure_message
          "expected block to #{description}, but #{positive_failure_reason}"
        end

        def failure_message_when_negated
          "expected block to not #{description}, but #{negative_failure_reason}"
        end

        def description
          "perform below #{@threshold} threshold"
        end

        def actual
          "%.6f (± %.6f) seconds" % [@average, @stddev]
        end

        def positive_failure_reason
          return 'was not a block' unless @block.is_a?(Proc)
          "performed above #{actual} "
        end

        def negative_failure_reason
          return 'was not a block' unless @block.is_a?(Proc)
          "performed #{actual} below"
        end
      end # Matcher

      def perform_below(threshold, options = {})
        Matcher.new(threshold, options)
      end
    end # TiminingMatcher
  end # Benchmark
end # RSpec
