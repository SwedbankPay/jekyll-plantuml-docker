# frozen_string_literal: true

require 'jekyll'
require_relative '../extensions/object_extensions'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::Commands module contains the implementations of the
    # various commands that Jekyll PlantUML supports.
    module Commands
      # The Jekyll::PlantUml::JekyllCommander class is a base class for
      # JekyllBuilder and JekyllServer.
      class JekyllCommander
        attr_writer :logger

        def initialize(jekyll_config, log_level)
          jekyll_config.must_be_a! :non_empty, Hash

          @jekyll_config = jekyll_config
          @log_level = log_level
        end

        def execute
          Jekyll.logger = @logger unless @logger.nil?
          Jekyll.logger.log_level = @log_level.to_sym unless @log_level.nil?
        end
      end
    end
  end
end
