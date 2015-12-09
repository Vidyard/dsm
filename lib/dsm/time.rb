require 'benchmark'

module Dsm
  class Time

    attr_accessor :total_duration, :recent_duration, :overall_average, :recent_average, :estimate

    def initialize
      @recent_durations = []
      @total_duration = 0.0
    end

    def measure(iteration, iterations_remaining)
      @recent_duration = Benchmark.realtime do
        yield
      end
      @recent_durations.shift() if @recent_durations.size == 10
      @recent_durations.push(@recent_duration)
      @total_duration += @recent_duration
      @overall_average = (@total_duration / iteration)
      @recent_average = (@recent_durations.inject{ |sum, el| sum + el }.to_f / @recent_durations.size)

      total_seconds_remaining = (iterations_remaining * @recent_average).round(0)
      minutes = (total_seconds_remaining / 60.0).floor
      @estimate = {
        :hours => (minutes / 60.0).floor,
        :minutes => minutes % 60,
        :seconds => total_seconds_remaining % 60,
        :total_seconds => total_seconds_remaining
      }
    end
  end
end
