# frozen_string_literal: true

require_relative 'options'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::ConsoleLogger class logs to the console.
    class ConsoleLogger
      def log(severity, message)
        severities = %i[trace debug info warn error fatal]
        level_index = severities.index(@log_level)
        severity_index = severities.index(severity)

        return if level_index.nil?
        return if level_index > severity_index

        puts "   jekyll-plantuml: #{message}"
      end

      def self.from_argv(argv)
        options = Options.new(argv)
        new(options.log_level)
      end

      private

      def initialize(log_level)
        @log_level = log_level
      end
    end
  end
end
