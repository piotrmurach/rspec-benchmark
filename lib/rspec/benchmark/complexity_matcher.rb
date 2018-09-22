# frozen_string_literal: true

require 'benchmark-trend'

module RSpec
  module Benchmark
    module ComplexityMatcher
      # Implements the `perform`
      #
      # @api public
      class Matcher
        def initialize(fit_type, **options)
          @fit_type  = fit_type
          @threshold = options.fetch(:threshold) { 0.9 }
          @range     = ::Benchmark::Trend.range(8, 8 << 10)
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
          "perform_#{@fit_type}"
        end

        # @return [Boolean]
        #
        # @api private
        def matches?(block)
          @trend, _ = ::Benchmark::Trend.infer_trend(@range, &block)

          @trend == @fit_type
        end

        def within(start, limit, ratio: 8)
          @range = ::Benchmark::Trend.range(start, limit, ratio: 8)
          self
        end

        def actual
          @trend
        end

        # @api private
        def description
          "perform #{@fit_type}"
        end

        # @api private
        def failure_message
          "expected block to #{description}, but #{failure_reason}"
        end

        def failure_message_when_negated
          "expected block not to #{description}, but #{failure_reason}"
        end

        def failure_reason
          "performed #{actual}"
        end
      end # Matcher
    end # ComplexityMatcher
  end # Benchmark
end # RSpec
