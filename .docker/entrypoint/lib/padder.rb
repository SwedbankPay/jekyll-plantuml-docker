# frozen_string_literal: true

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::Padder class performs string padding on lines based
    # on the number of lines being written.
    class Padder
      def initialize(pad_length, debug = false)
        @pad_length = pad_length
        @debug = debug
        @padding = ' '.rjust(pad_length)
      end

      def write(message, line_number = nil)
        unless line_number.nil?
          line_number_s = line_number.to_s.rjust(@pad_length)
          puts "#{line_number_s}: #{message}" if @debug
          return
        end

        puts "#{@padding}  #{message}" if @debug
      end
    end
  end
end
