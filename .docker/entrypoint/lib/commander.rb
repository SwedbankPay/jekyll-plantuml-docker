# frozen_string_literal: true

require 'jekyll'
require_relative 'argument_parser'
require_relative 'command_line_argument_error'
require_relative 'commands/deployer'
require_relative 'commands/verifier'
require_relative 'commands/jekyll_builder'
require_relative 'commands/jekyll_server'
require_relative 'commands/default_commands'
require_relative 'extensions/object_extensions'
require_relative 'jekyll_config_provider'

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
        parsed_args = @argument_parser.parse(args)
        execute_args(parsed_args)
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

      def execute_args(args)
        command = find_command(args)
        verify = args['--verify']
        dry_run = args['--dry-run']
        ignore_urls = args['--ignore-url']
        log_level = args['--log-level']
        jekyll_config_provider = JekyllConfigProvider.new(@exec_env, log_level)
        jekyll_config = jekyll_config_provider.provide(command)
        execute_command(jekyll_config, command, dry_run, verify, log_level)
        verify(jekyll_config, ignore_urls, log_level) if verify
      end

      def find_command(args)
        return 'build' if args['build'] == true
        return 'serve' if args['serve'] == true
        return 'deploy' if args['deploy'] == true

        raise CommandLineArgumentError, 'Unkonw command'
      end

      def execute_command(jekyll_config, command, dry_run, verify, log_level)
        case command
        when 'deploy'
          deploy(jekyll_config, verify, dry_run)
        when 'build'
          build(jekyll_config, dry_run, log_level)
        when 'serve'
          serve(jekyll_config, dry_run, log_level)
        else
          raise CommandLineArgumentError, "Unknown command '#{command}'"
        end
      end

      def verify(jekyll_config, ignore_urls, log_level)
        verifier = @commands.verifier.new(jekyll_config, log_level)
        verifier.verify(ignore_urls)
      end

      def deploy(jekyll_config, verify, dry_run)
        deployer = @commands.deployer.new(jekyll_config, @exec_env.var_dir)
        deployer.logger = @logger unless @logger.nil?
        deployer.deploy(dry_run, verify)
      end

      def build(jekyll_config, dry_run, log_level)
        log(:warn, 'Warning: --dry-run has no effect on the `jekyll build` command.') if dry_run

        jekyll_builder = @commands.builder.new(jekyll_config, log_level)
        jekyll_builder.logger = @logger unless @logger.nil?
        jekyll_builder.execute
      end

      def serve(jekyll_config, dry_run, log_level)
        log(:warn, 'Warning: --dry-run has no effect on the `jekyll serve` command.') if dry_run

        jekyll_server = @commands.server.new(jekyll_config, log_level)
        jekyll_server.logger = @logger unless @logger.nil?
        jekyll_server.execute
      end
    end
  end
end
