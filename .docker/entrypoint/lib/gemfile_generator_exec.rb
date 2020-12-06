# frozen_string_literal: true

require 'jekyll'
require_relative 'gemfile_generator'
require_relative 'environment_variables'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::GemfileGeneratorExec executes the GemfileGenerator
    # by bootstrapping the environment.
    class GemfileGeneratorExec
      attr_reader :logger

      def initialize(gemfiles = nil)
        env = EnvironmentVariables.new(default_data_dir: Dir.pwd, default_var_dir: Dir.pwd)
        gemfiles ||= {
          default: File.join(env.var_dir, 'entrypoint', 'Gemfile'),
          user: File.join(env.data_dir, 'Gemfile'),
          generated: File.join(env.data_dir, 'Gemfile.generated')
        }
        @gemfiles = gemfiles
      end

      def generate
        gemfiles_info

        gemfile_generator = GemfileGenerator.new
        gemfile_generator.logger = @logger
        gemfile_generator.generate(
          @gemfiles[:default],
          @gemfiles[:user],
          @gemfiles[:generated]
        )
      end

      def logger=(logger)
        @logger = logger
      end

      private

      def gemfiles_info
        log(:debug, 'Gemfiles:')
        @gemfiles.each do |type, path|
          gemfile_info(type, path)
        end
      end

      def gemfile_info(type, gemfile_path)
        gemfile_exists = File.exist? gemfile_path

        log(:debug, "  - type: #{type}")
        log(:debug, "    path: #{gemfile_path}")
        log(:debug, "    exists: #{gemfile_exists}")

        return unless gemfile_exists

        uid = File.stat(gemfile_path).uid
        gid = File.stat(gemfile_path).gid
        log(:debug, "    uid: #{uid}")
        log(:debug, "    gid: #{gid}")
      end


      def log(severity, message)
        (@logger ||= Jekyll.logger).public_send(
          severity,
          "   jekyll-plantuml: #{message}"
        )
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  # We set STDOUT.sync to disasble buffering
  $stdout.sync = true
  # This will only run if the script was the main, not loaded or required
  Jekyll::PlantUml::GemfileGeneratorExec.new.generate
end
