# frozen_string_literal: true

require_relative 'gemfile_generator'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::GemfileGeneratorExec executes the GemfileGenerator
    # by bootstrapping the environment.
    class GemfileGeneratorExec
      def initialize(gemfiles = nil)
        @debug = ENV.fetch('DEBUG', false)
        jekyll_data_dir = ENV.fetch('JEKYLL_DATA_DIR', Dir.pwd)
        jekyll_var_dir = ENV.fetch('JEKYLL_VAR_DIR', Dir.pwd)
        gemfiles ||= {
          default: File.join(jekyll_var_dir, 'entrypoint', 'Gemfile'),
          user: File.join(jekyll_data_dir, 'Gemfile'),
          generated: File.join(jekyll_data_dir, 'Gemfile.generated')
        }
        @gemfiles = gemfiles
      end

      def generate
        gemfiles_info

        gemfile_generator = GemfileGenerator.new(debug: @debug)

        gemfile_generator.generate(
          @gemfiles[:default],
          @gemfiles[:user],
          @gemfiles[:generated]
        )
      end

      private

      def gemfiles_info
        return unless @debug

        puts 'Gemfiles:'
        @gemfiles.each do |type, path|
          gemfile_info(type, path)
        end
      end

      def gemfile_info(type, gemfile_path)
        gemfile_exists = File.exist? gemfile_path

        puts "  - type: #{type}"
        puts "    path: #{gemfile_path}"
        puts "    exists: #{gemfile_exists}"

        return unless gemfile_exists

        uid = File.stat(gemfile_path).uid
        gid = File.stat(gemfile_path).gid
        puts "    uid: #{uid}"
        puts "    gid: #{gid}"
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
