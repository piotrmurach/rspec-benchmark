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
          return false unless Proc === block
          @bench = ::Benchmark::Performance.new
          @average, @stddev = @bench.run(@samples, &block)
          (@average = @average.round(@scale)) <= @threshold
        end

        def does_not_match?(block)
          !matches?(block) && Proc === block
        end

        def and_sample(samples)
          @samples = samples
          self
        end

        def failure_message
          msg = "expected block to #{description}, but "
          if !(Proc === @block)
            msg << "was not a block"
          else
            msg << "performed above #{@average} "
          end
          msg
        end

        def failure_message_when_negated
          msg = "expected block to not #{description}, but "
          if !(Proc === @block)
            msg << "was not a block"
          else
            msg << "performed #{@average} below"
          end
          msg
        end

        def description
          "perform below #{@threshold} threshold"
        end
      end # Matcher

      def perform_below(threshold, options = {})
        Matcher.new(threshold, options)
      end
    end # TiminingMatcher
  end # Benchmark
end # RSpec
