module Dsm
  class Chunker

    DEFAULT_STRIDE = 1000
    DEFAULT_THROTTLE = 200
    DEFAULT_START_ID = 1

    attr_accessor :stride, :throttle, :start_id, :end_id, :num_rows, :num_chunks, :num_chunks_requested, :next_start_id

    def initialize(table_name, options, connection)
      @stride = options[:stride] || DEFAULT_STRIDE
      @throttle = options[:throttle] || DEFAULT_THROTTLE
      @start_id = options[:start_id] || DEFAULT_START_ID
      @next_start_id = @start_id
      @end_id = options[:end_id] || connection.select_value("SELECT MAX(id) AS max_id FROM `#{table_name}`") || 1
      @end_id = @end_id.to_i

      @num_rows = @end_id - @start_id + 1
      @num_chunks = (@num_rows / @stride.to_f).ceil
      @num_chunks_requested = 0
    end

    def get_next_range
      range = {
        :begin_range => @next_start_id,
        :end_range => [@next_start_id + @stride - 1, @end_id].min
      }
      @next_start_id += @stride
      @num_chunks_requested += 1
      return range
    end

  end
end
