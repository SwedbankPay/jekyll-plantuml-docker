# frozen_string_literal: true

require_relative 'console_logger'
require_relative 'gemfile_generator'
require_relative 'environment_variables'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::GemfileGeneratorExec executes the GemfileGenerator
    # by bootstrapping the environment.
    class GemfileGeneratorExec
      def initialize(gemfiles: nil, args: nil)
        env = EnvironmentVariables.new(default_data_dir: Dir.pwd, default_var_dir: Dir.pwd)
        gemfiles ||= {
          default: File.join(env.var_dir, 'entrypoint', 'Gemfile'),
          user: File.join(env.data_dir, 'Gemfile'),
          generated: File.join(env.data_dir, 'Gemfile.generated')
        }
        @gemfiles = gemfiles
        @logger = ConsoleLogger.from_argv(args)
      end

      def generate
        gemfiles_info

        gemfile_generator = GemfileGenerator.new(@logger)
        gemfile_generator.generate(
          @gemfiles[:default],
          @gemfiles[:user],
          @gemfiles[:generated]
        )
      end

      private

      def gemfiles_info
        @logger.log(:debug, 'Gemfiles:')
        @gemfiles.each do |type, path|
          gemfile_info(type, path)
        end
      end

      def gemfile_info(type, gemfile_path)
        gemfile_exists = File.exist? gemfile_path

        @logger.log(:debug, "  - type: #{type}")
        @logger.log(:debug, "    path: #{gemfile_path}")
        @logger.log(:debug, "    exists: #{gemfile_exists}")

        return unless gemfile_exists

        uid = File.stat(gemfile_path).uid
        gid = File.stat(gemfile_path).gid
        @logger.log(:debug, "    uid: #{uid}")
        @logger.log(:debug, "    gid: #{gid}")
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  # We set STDOUT.sync to disasble buffering
  $stdout.sync = true
  # This will only run if the script was the main, not loaded or required
  Jekyll::PlantUml::GemfileGeneratorExec.new(args: ARGV).generate
end
