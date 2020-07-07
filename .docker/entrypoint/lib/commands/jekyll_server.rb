# frozen_string_literal: true

require 'jekyll'
require_relative 'jekyll_commander'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::Commands module contains the implementations of the
    # various commands that Jekyll PlantUML supports.
    module Commands
      # The Jekyll::PlantUml::JekyllBuilder class executes the Jekyll command
      # 'serve'.
      class JekyllServer < JekyllCommander
        def execute
          super
          Jekyll::Commands::Serve.process(@context.configuration)
        end
      end
    end
  end
end
