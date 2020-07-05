# frozen_string_literal: true

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::CommandLineArgumentError is raised when there's an
    # error in the command line arguments.
    class CommandLineArgumentError < ArgumentError
      def initialize(message = 'Invalid argument')
        super(message)
      end
    end
  end
end
