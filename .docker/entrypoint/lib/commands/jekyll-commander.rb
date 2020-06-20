# frozen_string_literal: true

require 'jekyll'
require 'jekyll-github-metadata'
require_relative '../command-line-argument-error'
require_relative 'jekyll-config-provider'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::JekyllCommander class executes Jekyll commands such
    # as `build` and `serve` against the correct `Jekyll::Commands::*` class.
    class JekyllCommander
      def initialize(jekyll_config)
        @jekyll_config = jekyll_config
      end

      def execute(requested_jekyll_command)
        jekyll_command_class = nil
        jekyll_command = requested_jekyll_command.downcase

        case jekyll_command
        when 'build'
          jekyll_command_class = Jekyll::Commands::Build
        when 'serve'
          jekyll_command_class = Jekyll::Commands::Serve
        else
          raise CommandLineArgumentError, "Unsupported Jekyll command '#{requested_jekyll_command}'"
        end

        jekyll_command_class.process(@jekyll_config)
      end
    end
  end
end
