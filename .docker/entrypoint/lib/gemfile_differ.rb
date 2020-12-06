# frozen_string_literal: true

require 'bundler'
require_relative 'errors/file_not_found_error'
require_relative 'extensions/object_extensions'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::GemfileDiffer class performs diffing of Gemfiles.
    class GemfileDiffer
      attr_accessor :logger

      def diff(default_gemfile_path, user_gemfile_path, &block)
        default_gemfile_path.must_be_a_file!

        log(:debug, "\n\n----- Sourcing gems from #{user_gemfile_path} -----")
        user_dependencies = load_dependencies(user_gemfile_path)

        log(:debug, "\n\n----- Sourcing gems from #{default_gemfile_path} -----")
        default_dependencies = load_dependencies(default_gemfile_path)

        do_diff(default_dependencies, user_dependencies, &block)
      end

      private

      def load_dependencies(path)
        definition = build_definition(path)
        return [] if definition.nil?

        dependencies = definition.dependencies
        log(:debug, dependencies)
        dependencies
      end

      def build_definition(path)
        return nil unless path.writable_file?

        begin
          return Bundler::Definition.build(path, nil, {})
        rescue Bundler::GemfileNotFound => e
          log(:debug, e)
        end

        nil
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
        return -1 if version_a.nil?
        return 1 if version_b.nil?
        return 1 if version_a > version_b

        -1
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
