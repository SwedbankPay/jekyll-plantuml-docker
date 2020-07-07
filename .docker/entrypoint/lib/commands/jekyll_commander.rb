# frozen_string_literal: true

require 'jekyll'
require_relative '../context'
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

        def initialize(context)
          context.must_be_a! Context

          @context = context
        end

        def execute
          Jekyll.logger = @logger unless @logger.nil?
          log_level = @context.arguments.log_level
          Jekyll.logger.log_level = log_level.to_sym unless log_level.nil?
        end
      end
    end
  end
end
