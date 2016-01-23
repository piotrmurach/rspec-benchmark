# encoding: utf-8

module RSpec
  module Benchmark
    # Format time for easy matcher reporting
    #
    # @param [Float] time
    #   the time to format
    #
    # @return [String]
    #   the human readable time value
    #
    # @api public
    def format_time(time)
      if time >= 100.0
        "%.0f sec" % [time]
      elsif time >= 1.0
        "%.3g sec" % [time]
      elsif time >= 1e-3
        "%.3g ms" % [time * 1e3]
      elsif time >= 1e-6
        "%.3g μs" % [time * 1e6]
      else
        "%.0f ns" % [time * 1e9]
      end
    end
    module_function :format_time
  end # Benchmark
end # RSpec
