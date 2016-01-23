# encoding: utf-8

require 'benchmark'

module Benchmark
  module Perf
    # Calculate arithemtic average of measurements
    #
    # @param [Array[Float]] measurements
    #
    # @return [Float]
    #   the average of given measurements
    #
    # @api public
    def average(measurements)
      return 0 if measurements.empty?
      measurements.reduce(&:+).to_f / measurements.size
    end

    # Calculate standard deviation
    #
    # @param [Array[Float]] measurements
    #
    # @api public
    def std_dev(measurements)
      return 0 if measurements.empty?
      average = average(measurements)
      Math.sqrt(
        measurements.reduce(0) do |sum, x|
          sum + (x - average)**2
        end.to_f / (measurements.size - 1)
      )
    end

    # Run given work and gather time statistics
    #
    # @api public
    def assert_perform_under(threshold, options = {}, &work)
      bench = ::Benchmark::Perf::ExecutionTime.new(options)
      actual, _ = bench.run(&work)
      actual <= threshold
    end

    # Assert work is performed within expected iterations per second
    #
    # @api public
    def assert_perform_ips(iterations, options = {}, &work)
      bench = ::Benchmark::Perf::Iteration.new(options)
      mean, stddev, _ = bench.run(&work)
      iterations <= (mean + 3 * stddev)
    end

    # Measure length of time the work could take on average
    #
    # @api private
    class ExecutionTime
      attr_reader :io

      # @param options :warmup
      #   the number of cycles for warmup, default 1
      #
      def initialize(options = {})
        @io = options.fetch(:io) { nil }
        @samples = options.fetch(:samples) { 30 }
      end

      # Set of ranges in linear progression
      #
      # @api private
      def linear_range(min, max, step = 1)
        (min..max).step(step).to_a
      end

      def bench_range
        linear_range(1, @samples)
      end

      # Isolate run in subprocess
      #
      # @api private
      def run_in_subprocess
        return yield unless Process.respond_to?(:fork)

        reader, writer = IO.pipe
        pid = Process.fork do
          GC.start
          GC.disable if ENV['BENCH_DISABLE_GC']
          reader.close

          time = yield

          io.print "%9.6f" % time if io
          writer.write(Marshal.dump(time))
          GC.enable if ENV['BENCH_DISABLE_GC']
          exit!(0) # run without hooks
        end

        writer.close
        Process.waitpid(pid)
        Marshal.load(reader.read)
      end

      def run_warmup(&work)
        run_in_subprocess { ::Benchmark.realtime(&work) }
      end

      # Perform work x times
      #
      # @api public
      def run(times = (not_set = true), &work)
        range = not_set ? bench_range : (0..times)
        measurements = []
        run_warmup(&work)

        range.each do
          GC.start

          measurements << run_in_subprocess do
            ::Benchmark.realtime(&work)
          end
        end
        io.puts if io

        [Perf.average(measurements), Perf.std_dev(measurements)]
      end
    end # ExecutionTime

    # Measure number of iterations a work could take in a second
    #
    # @api private
    class Iteration
      MICROSECONDS_PER_SECOND = 1_000_000
      MICROSECONDS_PER_100MS = 100_000

      def initialize(options = {})
        @time   = options.fetch(:time) { 2 } # Default 2 seconds for measurement
        @warmup = options.fetch(:warmup) { 1 }
      end

      # Call work by given times
      #
      # @param [Integer] times
      #   the times to call
      #
      # @return [Integer]
      #   the number of times worke has been called
      #
      # @api private
      def call_times(times)
        i = 0
        while i < times
          yield
          i += 1
        end
      end

      # Calcualte the number of cycles needed for 100ms
      #
      # @param [Integer] iterations
      # @param [Float] elapsed_time
      #   the total time for all iterations
      #
      # @return [Integer]
      #   the cycles per 100ms
      #
      # @api private
      def cycles_per_100ms(iterations, elapsed_time)
        cycles = (iterations * (MICROSECONDS_PER_100MS / elapsed_time)).to_i
        cycles <= 0 ? 1 : cycles
      end

      # Warmup run
      #
      # @api private
      def run_warmup(&work)
        GC.start
        target = Time.now + @warmup
        iter = 0

        elapsed_time = ::Benchmark.realtime do
          while Time.now < target
            call_times(1, &work)
            iter += 1
          end
        end

        elapsed_time *= MICROSECONDS_PER_SECOND
        cycles_per_100ms(iter, elapsed_time)
      end

      # Run measurements
      #
      # @api public
      def run(&work)
        target = Time.now + @time
        iter = 0
        measurements = []
        cycles = run_warmup(&work)

        GC.start

        while Time.now < target
          time = ::Benchmark.realtime { call_times(cycles, &work) }
          next if time <= 0.0 # Iteration took no time
          iter += cycles
          measurements << time * MICROSECONDS_PER_SECOND
        end

        ips = measurements.map do |time_ms|
          (cycles / time_ms) * MICROSECONDS_PER_SECOND
        end

        final_time = Time.now
        elapsed_time = (final_time - target).abs

        [Perf.average(ips).round, Perf.std_dev(ips).round, iter, elapsed_time]
      end
    end # Iteration

    extend Benchmark::Perf
  end # Perf
end # Benchmark
