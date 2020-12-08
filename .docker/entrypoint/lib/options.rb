# frozen_string_literal: true

require 'optparse'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::Options is an external dependency-free class that
    # parses console arguments. Will hopefully replace ArgumentParser and Docopt
    # over time, as they can't be used without first doing 'bundle install'.
    # Currently only supports #log_level.
    class Options
      attr_reader :log_level

      def initialize(args)
        @log_level = find_log_level(args)
      end

      private

      def find_log_level(args)
        return :fatal if args.nil? || args.empty?

        options = parse(args)
        return options[:log_level].to_sym if options.key?(:log_level)

        :fatal
      end

      def parse(args)
        options = {}

        OptionParser.new do |opt|
          opt.on('--log-level LOG_LEVEL', '--log-level=LOG_LEVEL') { |o| options[:log_level] = o }
        end.parse!(args)

        options
      end
    end
  end
end
