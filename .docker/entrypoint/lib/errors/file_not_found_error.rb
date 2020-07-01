# frozen_string_literal: true

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # Thrown when files are not found
    class FileNotFoundError < StandardError
      attr_reader :original

      def initialize(msg, original = nil)
        super(msg)
        @original = original
      end
    end
  end
end
