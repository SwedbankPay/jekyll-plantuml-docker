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

      def initialize(exec_env, docker_image)
        exec_env.must_be_a! ExecEnv
        docker_image.must_be_a! DockerImage

        @exec_env = exec_env
        @argument_parser = ArgumentParser.new(docker_image)
        @commands = Jekyll::PlantUml::Commands::DefaultCommands.new
      end

      def execute(args = nil)
        arguments = @argument_parser.parse(args)
        execute_args(arguments)
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

      def execute_args(arguments)
        log_level = arguments.log_level
        jekyll_config_provider = JekyllConfigProvider.new(@exec_env, log_level)
        jekyll_config = jekyll_config_provider.provide(arguments.command)
        execute_command(jekyll_config, arguments)
        verify(jekyll_config, arguments) if arguments.verify?
      end

      def execute_command(jekyll_config, arguments)
        case arguments.command
        when 'deploy'
          deploy(jekyll_config, arguments)
        when 'build'
          build(jekyll_config, arguments)
        when 'serve'
          serve(jekyll_config, arguments)
        else
          raise CommandLineArgumentError, "Unknown command '#{command}'"
        end
      end

      def verify(jekyll_config, arguments)
        verifier = @commands.verifier.new(jekyll_config, arguments.log_level)
        verifier.verify(arguments.ignore_urls)
      end

      def deploy(jekyll_config, arguments)
        environment = arguments.environment
        warn_of_development_environment if environment == 'development'
        deployer = @commands.deployer.new(jekyll_config, @exec_env.var_dir)
        deployer.logger = @logger unless @logger.nil?
        deployer.deploy(arguments.dry_run?, arguments.verify?)
      end

      def build(jekyll_config, arguments)
        warn_of_dry_run if arguments.dry_run?
        log_level = arguments.log_level
        jekyll_builder = @commands.builder.new(jekyll_config, log_level)
        jekyll_builder.logger = @logger unless @logger.nil?
        jekyll_builder.execute
      end

      def serve(jekyll_config, arguments)
        warn_of_dry_run if arguments.dry_run?
        log_level = arguments.log_level
        jekyll_server = @commands.server.new(jekyll_config, log_level)
        jekyll_server.logger = @logger unless @logger.nil?
        jekyll_server.execute
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
