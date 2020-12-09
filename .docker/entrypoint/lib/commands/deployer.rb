# frozen_string_literal: false

require 'jekyll'
require_relative 'deployer_exec'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::Commands module contains the implementations of the
    # various commands that Jekyll PlantUML supports.
    module Commands
      # The Jekyll::PlantUml::Deployer deploys a built Jekyll site to a specified
      # branch (default `gh-pages`) and pushes that branch to the remote `origin`.
      class Deployer
        attr_writer :jekyll_build, :logger

        def initialize(context)
          context.must_be_a! Context

          @context = context
          @deployer_exec = DeployerExec.new(context)
        end

        def deploy
          message = 'Deploying'
          message << ', dry-run' if @context.arguments.dry_run?
          message << ', verified' if @context.arguments.verify?
          message << '…'

          log(:info, message)

          jekyll_build.process(@context.configuration)
          @deployer_exec.logger = @logger unless @logger.nil?
          @deployer_exec.execute
        end

        def jekyll_build
          @jekyll_build ||= Jekyll::Commands::Build
        end

        private

        def log(severity, message)
          (@logger ||= Jekyll.logger).public_send(
            severity,
            "   jekyll-plantuml: #{message}"
          )
        end
      end
    end
  end
end
