# encoding: utf-8

module RSpec
  module Benchmark
    module IterationMatcher
      # Implements the `perform_at_least` matcher
      #
      # @api private
      class Matcher
        def initialize(iterations, options = {})
          @iterations = iterations
        end

        def supports_block_expectations?
          true
        end

        def matches?(block)
          @bench = ::Benchmark::Iteration.new
          @actual, _ = @bench.run(&block)
          @actual >= @iterations
        end

        def ips
          self
        end

        def failure_message
          "expected block to #{description}, but #{positive_failure_reason}"
        end

        def failure_message_when_negated
          "expected block not to #{description}, but #{negative_failure_reason}"
        end

        def description
          "perform at least #{@iterations} iterations per second"
        end

        def positive_failure_reason
          "performed only #{@actual} within second"
        end

        def negative_failure_reason
          "performed #{@actual} within second"
        end
      end

      def perform_at_least(iterations, options = {})
        Matcher.new(iterations, options)
      end
    end # IterationMatcher
  end # Benchmark
end # RSpec
