# frozen_string_literal: true

require 'jekyll'
require_relative 'argument_parser'
require_relative 'jekyll_config_provider'
require_relative 'commands/deployer'
require_relative 'commands/verifier'
require_relative 'commands/jekyll_builder'
require_relative 'commands/jekyll_server'
require_relative 'commands/default_commands'
require_relative 'extensions/object_extensions'
require_relative 'errors/command_line_argument_error'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::Commander class is responsible for retrieving the
    # arguments from ArgumentParser, the configuration from JekyllConfigProvider
    # and execute the correct command according to the provided arguments.
    class Commander
      attr_reader :commands
      attr_writer :logger

      def initialize(context, docker_image)
        context.must_be_a! Context
        docker_image.must_be_a! DockerImage

        @context = context
        @argument_parser = ArgumentParser.new(docker_image)
        @commands = Jekyll::PlantUml::Commands::DefaultCommands.new
      end

      def execute(args = nil)
        @context.arguments = @argument_parser.parse(args)
        execute_args
      rescue Docopt::Exit => e
        log(:info, e.message)
      rescue CommandLineArgumentError => e
        log(:error, "Error! #{e}.\n#{@argument_parser.help}")
        exit 1
      end

      private

      def log(severity, message)
        (@logger ||= Jekyll.logger).public_send(
          severity,
          "   jekyll-plantuml: #{message}"
        )
      end

      def execute_args
        configure
        execute_command
        verify if @context.arguments.verify?
      end

      def execute_command
        cmd = @context.arguments.command
        case cmd
        when 'deploy'
          deploy
        when 'build'
          build
        when 'serve'
          serve
        else
          raise CommandLineArgumentError, "Unknown command '#{cmd}'"
        end
      end

      def verify
        verifier = @commands.verifier.new(@context)
        verifier.verify
      end

      def deploy
        environment = @context.arguments.environment
        warn_of_development_environment if environment == 'development'
        deployer = @commands.deployer.new(@context)
        deployer.logger = @logger unless @logger.nil?
        deployer.deploy
      end

      def build
        warn_of_dry_run if @context.arguments.dry_run?
        jekyll_builder = @commands.builder.new(@context)
        jekyll_builder.logger = @logger unless @logger.nil?
        jekyll_builder.execute
      end

      def serve
        warn_of_dry_run if @context.arguments.dry_run?
        jekyll_server = @commands.server.new(@context)
        jekyll_server.logger = @logger unless @logger.nil?
        jekyll_server.execute
      end

      def configure
        command = @context.arguments.command
        jekyll_config_provider = JekyllConfigProvider.new(@context)
        jekyll_config = jekyll_config_provider.provide(command)
        @context.configuration = jekyll_config
      end

      def warn_of_dry_run
        msg = 'Warning: --dry-run has no effect on the `jekyll serve` command.'
        log(:warn, msg)
      end

      def warn_of_development_environment
        log(:warn, "Warning: Deploying in 'development' environment means")
        log(:warn, "jekyll-github-metadata won't affect the generated URLs.")
        log(:warn, "Use --env='production' to deploy in production mode.")
      end
    end
  end
end
