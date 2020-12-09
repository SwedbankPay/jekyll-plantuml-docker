# frozen_string_literal: true

require 'fileutils'
require_relative 'gemfile_differ'
require_relative 'errors/file_not_found_error'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::GemfileGenerator class in practice merges the
    # contents of two input Gemfiles into a generated third output Gemfile.
    class GemfileGenerator
      def initialize(logger)
        raise ArgumentError, 'Logger cannot be nil' if logger.nil?

        @logger = logger
        @gemfile_differ = GemfileDiffer.new(logger)
      end

      def generate(default_gemfile_path, user_gemfile_path, generated_gemfile_path = nil)
        raise FileNotFoundError, "#{default_gemfile_path} cannot be found." unless path_valid?(default_gemfile_path)

        unless path_valid? user_gemfile_path
          FileUtils.cp(default_gemfile_path, generated_gemfile_path)
          return
        end

        generated_file_contents = merge(default_gemfile_path, user_gemfile_path)

        return generated_file_contents if return_contents?(generated_gemfile_path, generated_file_contents)

        write_file(generated_gemfile_path, generated_file_contents)
      end

      private

      def merge(default_gemfile_path, user_gemfile_path)
        user_gemfile_contents = path_valid?(user_gemfile_path) ? File.readlines(user_gemfile_path) : []
        default_gemfile_contents = []

        @logger.log(:debug, "\n\n----- Merging <#{user_gemfile_path}> with <#{default_gemfile_path}> -----")

        @gemfile_differ.diff(default_gemfile_path, user_gemfile_path) do |dependency|
          # Delete dependencies that override the user's dependencies, most
          # likely because the default dependency has a higher version number.
          # Note that the dependencies are only deleted from the in-memory array
          # and not from the physical file system.
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
        @logger.log(:debug, "\n\n----- Writing <#{path}> -----")

        return if contents.empty?

        @logger.log(:debug, contents)

        File.open(path, 'w') do |file|
          file.puts(contents)
        end

        validate_gemfile(path)
      end

      def validate_gemfile(path)
        @logger.log(:debug, "\n\n----- Validating <#{path}> -----")

        if path_valid?(path)
          @logger.log(:debug, "#{path} exists.")
        else
          @logger.log(:warn, "#{path} DOES NOT EXIST! ALARM!")
        end

        Bundler::Definition.build(path, nil, {})
      end

      def path_valid?(path)
        return true if !path.nil? && !path.empty? && File.exist?(path)

        @logger.log(:debug, "<#{path}> not found.")

        false
      end

      def return_contents?(path, contents)
        @logger.log(:debug, "\n\n----- <#{path}> contents -----")
        @logger.log(:debug, contents)

        if path.nil?
          @logger.log(:debug, 'Returning contents since the path on which to save it is nil.')
          return true
        end

        false
      end
    end
  end
end
