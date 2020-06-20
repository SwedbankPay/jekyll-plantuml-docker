# frozen_string_literal: true

require 'jekyll'
require_relative 'argument-parser'
require_relative 'command-line-argument-error'
require_relative 'commands/deployer'
require_relative 'commands/verifier'
require_relative 'commands/jekyll-commander'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::Commander class is responsible for retrieving the
    # arguments from ArgumentParser, the configuration from JekyllConfigProvider
    # and execute the correct command according to the provided arguments.
    class Commander
      def initialize(jekyll_env, jekyll_data_dir, jekyll_var_dir, docker_image_name, docker_image_tag, docker_image_version)
        @argument_parser = ArgumentParser.new(docker_image_name, docker_image_tag, docker_image_version)
        @jekyll_config_provider = JekyllConfigProvider.new(jekyll_data_dir)
        @jekyll_var_dir = jekyll_var_dir
        @jekyll_env = jekyll_env
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
        (@logger ||= Jekyll.logger).public_send(severity, "jekyll-plantuml: #{message}")
      end

      def execute_args(args)
        command = args['<command>']
        jekyll_config = @jekyll_config_provider.get_config(command)

        case command
        when 'deploy'
          dry_run = args['--dry-run']
          verify = args['--verify']
          deployer = Deployer.new(jekyll_config, @jekyll_var_dir)
          deployer.deploy(dry_run, verify)
        when 'build', 'serve'
          log(:warn, "Warning: --dry-run has no effect on the `jekyll #{command}` command.") if args['--dry-run']

          jekyll_commander = JekyllCommander.new(jekyll_config)
          jekyll_commander.execute(command)
        else
          raise CommandLineArgumentError, "Unknown command '#{command}'"
        end

        return unless args['--verify']

        verifier = Verifier.new(jekyll_config)
        verifier.verify
      end
    end
  end
end
