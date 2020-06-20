# frozen_string_literal: true

require_relative 'gemfile-differ'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::GemfileGenerator class in practice merges the
    # contents of two input Gemfiles into a generated third output Gemfile.
    class GemfileGenerator
      def initialize(debug = false)
        @debug = debug
      end

      def generate(primary_gemfile_path, secondary_gemfile_path, generated_gemfile_path)
        raise "#{primary_gemfile_path} cannot be found." unless File.exist? primary_gemfile_path

        puts "Reading #{primary_gemfile_path}..." if @debug
        original_file = File.readlines File.join(primary_gemfile_path)
        generated_file = original_file

        puts "Diffing #{secondary_gemfile_path}..." if @debug
        gemfile_differ = Jekyll::PlantUml::GemfileDiffer.new(@debug)
        gemfile_differ.diff(primary_gemfile_path, secondary_gemfile_path) do |line|
          generated_file << line
        end

        puts "Generating #{generated_gemfile_path}..." if @debug
        File.open(generated_gemfile_path, 'w') { |file| file.puts(generated_file) }
      end
    end
  end
end
