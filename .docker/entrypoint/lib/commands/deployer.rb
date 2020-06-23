# frozen_string_literal: false

require 'jekyll'
require_relative 'deployer_exec'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::Deployer deploys a built Jekyll site to a specified
    # branch (default `gh-pages`) and pushes that branch to the remote `origin`.
    class Deployer
      attr_writer :jekyll_build

      def initialize(jekyll_config, jekyll_var_dir)
        @jekyll_config = jekyll_config
        @deployer_exec = DeployerExec.new(jekyll_var_dir)
      end

      def deploy(dry_run, verify)
        message = 'Deploying'
        message << ', dry-run' if dry_run
        message << ', verified' if verify
        message << '…'

        log(:info, message)

        jekyll_build.process(@jekyll_config)
        @deployer_exec.execute(dry_run)
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
