# encoding: utf-8

module RSpec
  module Benchmark
    module TimingMatcher
      # Implements the `perform_under` matcher
      #
      # @api private
      class Matcher
        include RSpec::Benchmark

        attr_reader :threshold

        def initialize(threshold, **options)
          @threshold = threshold
          @samples = options.fetch(:samples) { 30 }
          @scale = threshold.to_s.split(/\./).last.size
          @block = nil
          @confidence_interval = nil
          warmup = options.fetch(:warmup) { 1 }
          @bench = ::Benchmark::Perf::ExecutionTime.new(warmup: warmup)
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
          @block = block
          return false unless block.is_a?(Proc)
          @average, @stddev = @bench.run(@samples, &block)
          @average <= @threshold
        end

        def does_not_match?(block)
          !matches?(block) && block.is_a?(Proc)
        end

        def and_sample(samples)
          @samples = samples
          self
        end

        def secs
          self
        end
        alias_method :sec, :secs

        # Tell this matcher to convert threshold to ms
        # @api public
        def ms
          @threshold /= 1e3
          self
        end

        # Tell this matcher to convert threshold to us
        # @api public
        def us
          @threshold /= 1e6
          self
        end

        # Tell this matcher to convert threshold to ns
        # @api public
        def ns
          @threshold /= 1e9
          self
        end

        def failure_message
          "expected block to #{description}, but #{positive_failure_reason}"
        end

        def failure_message_when_negated
          "expected block to not #{description}, but #{negative_failure_reason}"
        end

        def description
          "perform under #{format_time(@threshold)}"
        end

        def actual
          "#{format_time(@average)} (± #{format_time(@stddev)})"
        end

        def positive_failure_reason
          return 'was not a block' unless @block.is_a?(Proc)
          "performed above #{actual} "
        end

        def negative_failure_reason
          return 'was not a block' unless @block.is_a?(Proc)
          "performed #{actual} under"
        end
      end # Matcher
    end # TiminingMatcher
  end # Benchmark
end # RSpec
