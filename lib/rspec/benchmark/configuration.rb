# frozen_string_literal: true

module RSpec
  module Benchmark
    class Configuration
      # Isolate benchmark time measurement in child process
      # By default false due to Rails loosing DB connections
      #
      # @api public
      attr_accessor :run_in_subprocess

      # GC is enabled to measure real performance
      #
      # @api public
      attr_accessor :disable_gc

      def initialize
        @run_in_subprocess = false
        @disable_gc = false
      end
    end # Configuration
  end # Benchmark
end # RSpec
