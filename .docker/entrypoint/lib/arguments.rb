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
      attr_reader :profile

      def initialize(args)
        args.must_be_a! :non_empty, Hash

        @command = find_command(args)
        @verify = args.value_for('--verify')
        @dry_run = args.value_for('--dry-run')
        @ignore_urls = args.value_for('--ignore-url')
        @log_level = args.value_for('--log-level')
        @profile = args.value_for('--profile')
        @environment = args.value_for('--env')
      end

      def verify?
        @verify
      end

      def dry_run?
        @dry_run
      end

      def profile?
        @profile
      end

      def self.default
        Arguments.new({
                        'build' => false,
                        'serve' => false,
                        'deploy' => false,
                        '--verify' => false,
                        '--dry-run' => false,
                        '--ignore-url' => false,
                        '--log-level' => nil,
                        '--env' => nil,
                        '--profile' => false
                      })
      end

      private

      def find_command(args)
        return 'build' if args.value_for('build') == true
        return 'serve' if args.value_for('serve') == true
        return 'deploy' if args.value_for('deploy') == true

        # Alias CommandLineArgumentError to save line length
        clae = CommandLineArgumentError

        # If Arguments.default invoked the constructor, we shouldn't raise
        raise clae, 'Unknown command' unless invoked_by_default?
      end

      def invoked_by_default?
        # Find the caller location that matches Arguments.default
        loc = caller_locations.find { |l| location_is_arguments_default?(l) }

        # If we find Arguments.default in the caller locations, return true
        !loc.nil?
      end

      def location_is_arguments_default?(location)
        path = location.absolute_path
        label = location.base_label

        # If the path of the caller location is equal to this file's path
        # and the caller location's base label (method name) is equal to
        # 'default', return true.
        path == __FILE__ && label == 'default'
      end
    end
  end
end
