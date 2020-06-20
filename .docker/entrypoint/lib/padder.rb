module Jekyll
  module PlantUml
    class Padder
      def initialize(pad_length, debug = false)
        @pad_length = pad_length
        @debug = debug
        @padding = "%#{pad_length}s" % "" + " "
      end

      def puts(message, line_number = nil)
        if line_number
          line_number = "%#{@pad_length}d" % line_number
          puts "#{line_number}: #{message}" if @debug
        else
          puts "#{@padding} #{message}" if @debug
        end
      end
    end
  end
end
