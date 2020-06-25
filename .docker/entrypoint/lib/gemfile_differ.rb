# frozen_string_literal: true

require 'bundler'
require_relative 'file_not_found_error'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::GemfileDiffer class performs diffing of Gemfiles.
    class GemfileDiffer
      def initialize(debug = false)
        @debug = debug
      end

      def diff(default_gemfile_path, user_gemfile_path)
        raise FileNotFoundError, "#{default_gemfile_path} cannot be found." unless path_valid?(default_gemfile_path)
        raise FileNotFoundError, "#{user_gemfile_path} cannot be found." unless path_valid?(user_gemfile_path)

        puts "\n\n----- Sourcing gems from #{user_gemfile_path} -----" if @debug
        user_dependencies = load_dependencies(user_gemfile_path)

        puts "\n\n----- Sourcing gems from #{default_gemfile_path} -----" if @debug
        default_dependencies = load_dependencies(default_gemfile_path)

        do_diff(default_dependencies, user_dependencies) do |dependency|
          yield dependency
        end
      end

      private

      def load_dependencies(path)
        return [] unless path_valid?(path)

        definition = nil

        begin
          definition = Bundler::Definition.build(path, nil, {})
        rescue Bundler::GemfileNotFound => e
          raise FileNotFoundError.new("#{path} not found", e)
        end

        dependencies = definition.dependencies
        puts dependencies if @debug
        dependencies
      end

      def path_valid?(path)
        return true if File.exist? path

        puts "#{path} not found." if @debug

        false
      end

      def do_diff(default_dependencies, user_dependencies)
        # user_dependencies comes from the user's Gemfile.
        user_dependencies.each do |user_dependency|
          higher_version_match = find_higher_version_match(default_dependencies, user_dependency)

          # If we find a matching gem in the entrypoint's Gemfile, yield it.
          yield higher_version_match unless higher_version_match.nil?
        end

        # default_dependencies comes from the entrypoint's Gemfile.
        default_dependencies.each do |default_dependency|
          missing = find_match(user_dependencies, default_dependency)

          # If we find a gem that isn't in the user's Gemfile, yield it.
          yield default_dependency if missing.nil?
        end
      end

      def find_match(other_dependencies, dependency)
        other_dependencies.each do |other_dependency|
          return other_dependency if other_dependency.name == dependency.name
        end

        nil
      end

      def find_higher_version_match(other_dependencies, dependency)
        other_dependency = find_match(other_dependencies, dependency)

        return nil if other_dependency.nil?

        dependency_version = find_version(dependency)
        other_dependency_version = find_version(other_dependency)
        version_comparison = version_compare(other_dependency_version, dependency_version)

        return other_dependency if version_comparison.positive?

        nil
      end

      def find_version(dependency)
        dependency.requirement.requirements.flatten.find { |r| r.is_a? Gem::Version }
      end

      def version_compare(version_a, version_b)
        return 0 if version_a.nil? && version_b.nil?
        return -1 if version_a.nil? && !version_b.nil?
        return 1 if !version_a.nil? && version_b.nil?
        return 1 if version_a > version_b

        -1
      end
    end
  end
end
