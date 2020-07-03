# frozen_string_literal: true

require_relative 'deployer'
require_relative 'verifier'
require_relative 'jekyll_builder'
require_relative 'jekyll_server'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::Commands module contains the different commands
    # that are available for commandeering by Jekyll::PlantUml::Commander.
    module Commands
      # The Jekyll::PlantUml::Commands::DefaultCommands class defines the
      # different commands that are available for commandeering by
      # Jekyll::PlantUml::Commander.
      class DefaultCommands
        attr_writer :verifier
        attr_writer :deployer
        attr_writer :builder
        attr_writer :server

        def verifier
          @verifier || Jekyll::PlantUml::Commands::Verifier
        end

        def deployer
          @deployer || Jekyll::PlantUml::Commands::Deployer
        end

        def builder
          @builder || Jekyll::PlantUml::Commands::JekyllBuilder
        end

        def server
          @server || Jekyll::PlantUml::Commands::JekyllServer
        end
      end
    end
  end
end
