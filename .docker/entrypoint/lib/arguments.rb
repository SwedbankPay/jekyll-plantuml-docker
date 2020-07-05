# frozen_string_literal: true

require 'docopt'
require_relative 'extensions/object_extensions'
require_relative 'errors/command_line_argument_error'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::Arguments class contains the arguments parsed from
    # the command line by Jekyll::PlantUml::ArgumentParser
    class Arguments
      attr_reader :command
      attr_reader :ignore_urls
      attr_reader :log_level
      attr_reader :environment

      def initialize(args)
        args.must_be_a! :non_empty, Hash

        @command = find_command(args)
        @verify = args.value_for('--verify')
        @dry_run = args.value_for('--dry-run')
        @ignore_urls = args.value_for('--ignore-url')
        @log_level = args.value_for('--log-level')
        @environment = args.value_for('--env')
      end

      def verify?
        @verify
      end

      def dry_run?
        @dry_run
      end

      private

      def find_command(args)
        return 'build' if args['build'] == true
        return 'serve' if args['serve'] == true
        return 'deploy' if args['deploy'] == true

        raise CommandLineArgumentError, 'Unkonw command'
      end
    end
  end
end
