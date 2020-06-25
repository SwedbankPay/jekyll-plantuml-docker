# frozen_string_literal: true

require_relative 'gemfile_differ'
require_relative 'file_not_found_error'

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

      def generate(default_gemfile_path, user_gemfile_path, generated_gemfile_path = nil)
        raise FileNotFoundError, "#{default_gemfile_path} cannot be found." unless path_valid?(default_gemfile_path)

        generated_file_contents = merge(default_gemfile_path, user_gemfile_path)

        puts "\n\n----- #{generated_gemfile_path} contents -----" if @debug
        puts generated_file_contents if @debug

        if generated_gemfile_path.nil?
          puts 'Returning generated Gemfile since generated_gemfile_path is nil.' if @debug
          return generated_file_contents
        end

        puts "\n\n----- Writing #{generated_gemfile_path} -----" if @debug

        write_file(generated_gemfile_path, generated_file_contents)
      end

      private

      def merge(default_gemfile_path, user_gemfile_path)
        user_gemfile_contents = path_valid?(user_gemfile_path) ? File.readlines(user_gemfile_path) : []
        default_gemfile_contents = []

        puts "\n\n----- Merging #{user_gemfile_path} with #{default_gemfile_path} -----" if @debug

        @gemfile_differ.diff(default_gemfile_path, user_gemfile_path) do |dependency|
          user_gemfile_contents = delete(dependency, user_gemfile_contents)
          default_gemfile_contents << "gem '#{dependency.name}', '#{dependency.requirement}'"
        end

        merged_gemfile_contents = user_gemfile_contents
        merged_gemfile_contents << default_gemfile_contents
      end

      def delete(dependency, contents)
        index = find(dependency, contents)
        contents.delete_at(index) if index > -1
        contents
      end

      def find(dependency, contents)
        index = -1

        contents.each_with_index do |line, i|
          next unless line.include? dependency.name

          index = i
          break
        end

        index
      end

      def write_file(path, contents)
        File.open(path, 'w') do |file|
          file.puts(contents)
        end

        Bundler::Definition.build(path, nil, {})
      end

      def path_valid?(path)
        return true if File.exist? path

        puts "#{path} not found." if @debug

        false
      end
    end
  end
end
