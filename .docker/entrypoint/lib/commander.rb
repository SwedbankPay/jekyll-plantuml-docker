# frozen_string_literal: true

require 'jekyll'
require_relative 'argument_parser'
require_relative 'command_line_argument_error'
require_relative 'commands/deployer'
require_relative 'commands/verifier'
require_relative 'commands/jekyll_commander'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::Commander class is responsible for retrieving the
    # arguments from ArgumentParser, the configuration from JekyllConfigProvider
    # and execute the correct command according to the provided arguments.
    class Commander
      attr_reader :commands

      def initialize(jekyll_env, docker_image)
        @argument_parser = ArgumentParser.new(docker_image)
        @jekyll_config_provider = JekyllConfigProvider.new(jekyll_env.data_dir)
        @jekyll_var_dir = jekyll_env.var_dir
        @jekyll_env = jekyll_env.env
        @commands = {
          verify: Jekyll::PlantUml::Commands::Verifier,
          deploy: Jekyll::PlantUml::Commands::Deployer,
          build: Jekyll::PlantUml::Commands::JekyllCommander,
          serve: Jekyll::PlantUml::Commands::JekyllCommander
        }
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
        jekyll_config = @jekyll_config_provider.provide(command)
        execute_command(jekyll_config, command, dry_run, verify)
        verify(jekyll_config, ignore_urls) if verify
      end

      def find_command(args)
        return 'build' if args['build'] == true
        return 'serve' if args['serve'] == true
        return 'deploy' if args['deploy'] == true

        raise CommandLineArgumentError, 'Unkonw command'
      end

      def execute_command(jekyll_config, command, dry_run, verify)
        case command
        when 'deploy'
          deploy(jekyll_config, verify, dry_run)
        when 'build', 'serve'
          jekyll_command(jekyll_config, command, dry_run)
        else
          raise CommandLineArgumentError, "Unknown command '#{command}'"
        end
      end

      def verify(jekyll_config, ignore_urls)
        verifier = provide_instance(:verify, jekyll_config)
        verifier.verify(ignore_urls)
      end

      def deploy(jekyll_config, dry_run, verify)
        deployer = provide_instance(:deploy, jekyll_config, @jekyll_var_dir)
        deployer.deploy(dry_run, verify)
      end

      def jekyll_command(jekyll_config, command, dry_run)
        log(:warn, "Warning: --dry-run has no effect on the `jekyll #{command}` command.") if dry_run

        jekyll_commander = provide_instance(command, jekyll_config)
        # jekyll_commander = Jekyll::PlantUml::Commands::JekyllCommander.new(jekyll_config)
        jekyll_commander.execute(command)
      end

      def provide_instance(command, *args)
        command_symbol = command.to_sym
        class_definition = @commands[command_symbol]
        raise ArgumentError, "No class definition found for command '#{command}'" if class_definition.nil?

        return class_definition unless class_definition.is_a? Class

        class_definition.new(*args)
      end
    end
  end
end
