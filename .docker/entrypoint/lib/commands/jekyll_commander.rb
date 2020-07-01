# frozen_string_literal: true

require 'jekyll'
require 'jekyll-github-metadata'
require_relative '../command_line_argument_error'
require_relative '../jekyll_config_provider'
require_relative '../extensions/object_extensions'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::Commands module contains the implementations of the
    # various commands that Jekyll PlantUML supports.
    module Commands
      # The Jekyll::PlantUml::JekyllCommander class executes Jekyll commands such
      # as `build` and `serve` against the correct `Jekyll::Commands::*` class.
      class JekyllCommander
        def initialize(jekyll_config)
          jekyll_config.must_be_a! Hash
          raise ArgumentError, 'jekyll_config cannot be empty' if jekyll_config.empty?

          @jekyll_config = jekyll_config
        end

        def execute(requested_jekyll_command)
          jekyll_command = requested_jekyll_command.downcase
          jekyll_command_class = get_jekyll_command_class(jekyll_command)
          jekyll_command_class.process(@jekyll_config)
        end

        private

        def get_jekyll_command_class(jekyll_command)
          case jekyll_command
          when 'build'
            Jekyll::Commands::Build
          when 'serve'
            Jekyll::Commands::Serve
          else
            raise CommandLineArgumentError, "Unsupported Jekyll command '#{requested_jekyll_command}'"
          end
        end
      end
    end
  end
end
