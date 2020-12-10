# frozen_string_literal: true

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::ArgumentStringBuilder class is the implementation
    # of Jekyll::PlantUml::Arguments#to_s.
    class ArgumentStringBuilder
      def initialize(arguments)
        arguments.must_be_a! Arguments

        @string = to_string(arguments)
      end

      def to_s
        @string
      end

      private

      def to_string(arguments)
        [
          command(arguments),
          environment(arguments),
          verify(arguments),
          dry_run(arguments),
          ignore_url(arguments),
          log_level(arguments),
          profile(arguments)
        ].compact.join(' ').strip
      end

      def command(arguments)
        return nil if arguments.command.nil? || arguments.command.empty?

        arguments.command
      end

      def environment(arguments)
        return nil if arguments.environment.nil? || arguments.environment.empty?

        "--env=#{arguments.environment}"
      end

      def verify(arguments)
        return nil unless arguments.verify?

        '--verify'
      end

      def dry_run(arguments)
        return nil unless arguments.dry_run?

        '--dry-run'
      end

      def ignore_url(arguments)
        return nil if !arguments.ignore_urls || arguments.ignore_urls.nil? || arguments.ignore_urls.empty?

        arguments.ignore_urls.map { |url| "--ignore-url=#{url}" }.join(' ')
      end

      def log_level(arguments)
        return nil if arguments.log_level.nil? || arguments.log_level.empty?

        "--log-level=#{arguments.log_level}"
      end

      def profile(arguments)
        return nil unless arguments.profile

        '--profile'
      end
    end
  end
end
