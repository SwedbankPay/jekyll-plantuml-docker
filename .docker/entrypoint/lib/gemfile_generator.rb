# frozen_string_literal: true

require_relative 'gemfile_differ'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::GemfileGenerator class in practice merges the
    # contents of two input Gemfiles into a generated third output Gemfile.
    class GemfileGenerator
      def initialize(debug = false)
        @debug = debug
        @gemfile_differ = GemfileDiffer.new(@debug)
      end

      def generate(primary_gemfile_path, secondary_gemfile_path, generated_gemfile_path = nil)
        raise "#{primary_gemfile_path} cannot be found." unless File.exist? primary_gemfile_path

        generated_file_contents = generate_file_contents(primary_gemfile_path, secondary_gemfile_path)

        puts "\n\n----- Generating #{generated_gemfile_path} -----" if @debug
        puts generated_file_contents if @debug

        if generated_gemfile_path.nil?
          puts 'Returning generated Gemfile since generated_gemfile_path is nil.' if @debug
          return generated_file_contents
        end

        write_file(generated_gemfile_path, generated_file_contents)
      end

      private

      def generate_file_contents(primary_gemfile_path, secondary_gemfile_path)
        puts "\n\n----- Reading #{primary_gemfile_path} -----" if @debug
        original_file_contents = File.readlines primary_gemfile_path
        generated_file_contents = original_file_contents
        puts original_file_contents if @debug

        puts "\n\n----- Diffing #{secondary_gemfile_path} -----" if @debug
        @gemfile_differ.diff(primary_gemfile_path, secondary_gemfile_path) do |line|
          generated_file_contents << line
        end

        generated_file_contents
      end

      def write_file(path, contents)
        File.delete path if File.exist? path
        file = File.open(path, File::CREAT | File::WRONLY | File::TRUNC)
        file.flock(File::LOCK_EX)
        file.puts(contents)
        file.flock(File::LOCK_UN)
      end
    end
  end
end
