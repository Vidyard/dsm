require 'dsm/chunker'
require 'dsm/time'

module Dsm
  class Invoker
    def initialize(table_name, options, connection)
      @table_name = table_name
      @options = options
      @connection = connection
      @chunker = Chunker.new(table_name, options, connection)
    end

    def run(&block)
      output = @options[:output] || STDOUT
      desc = @options[:desc] || "Migrating data for table: #{@table_name}"

      output.puts desc
      output.puts "Stride: #{@chunker.stride}"
      output.puts "Throttle: #{@chunker.throttle} ms (included in averages)"
      output.puts "Start Id: #{@chunker.start_id}"
      output.puts "End Id: #{@chunker.end_id}"

      time = ::Dsm::Time.new
      begin
        range = @chunker.get_next_range
        time.measure(@chunker.num_chunks_requested, @chunker.num_chunks - @chunker.num_chunks_requested) do
          begin
            block.call(range[:begin_range], range[:end_range])
          rescue => e
            output.puts "Error in range #{range[:begin_range]} to #{range[:end_range]}"
            raise e
          end
          sleep (@chunker.throttle/1000.0)
        end

        percent_complete = ((@chunker.num_chunks_requested / @chunker.num_chunks.to_f) * 100)
        percent_str = "#{percent_complete.round(0)}% complete [#{@chunker.num_chunks_requested}/#{@chunker.num_chunks}]"
        overall_avg_str = "Mean: #{time.overall_average.round(3)}s"
        recent_avg_str = "Recent Mean: #{time.recent_average.round(3)}s"
        duration_str = "Runtime: #{time.total_duration.round(3)}s"
        time_remaining_str = "Remaining: #{time.estimate[:hours]}:#{time.estimate[:minutes].to_s.rjust(2, '0')}:#{time.estimate[:seconds].to_s.rjust(2, '0')}"
        output.print "\r#{percent_str} | #{recent_avg_str} | #{overall_avg_str} | #{duration_str} | #{time_remaining_str}"
      end while @chunker.next_start_id <= @chunker.end_id

      output.puts " "
      output.puts " "
      output.puts "DONE!"
    end
  end
end
