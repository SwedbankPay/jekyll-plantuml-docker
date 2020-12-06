# frozen_string_literal: true

require 'jekyll'
require_relative 'arguments'
require_relative 'extensions/object_extensions'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::EnvironmentVariables class provides environment
    # variables
    class EnvironmentVariables
      attr_reader :env, :data_dir, :var_dir, :auth_token, :git_branch, :git_repository_url, :debug

      def initialize(default_data_dir: :undefined, default_var_dir: :undefined)
        @env = ENV.fetch('JEKYLL_ENV', 'production')
        @data_dir = get_env('JEKYLL_DATA_DIR', default_data_dir)
        @var_dir = get_env('JEKYLL_VAR_DIR', default_var_dir)
        @auth_token = ENV.fetch('JEKYLL_GITHUB_TOKEN', nil) || ENV.fetch('GITHUB_TOKEN', nil)
        @git_branch = ENV.fetch('GITHUB_BRANCH', nil)
        @git_repository_url = ENV.fetch('GITHUB_REPOSITORY_URL', nil)
        @debug = ENV.fetch('DEBUG', false)
      end

      private

      def get_env(key, default_value)
        return ENV.fetch(key) if (default_value == :undefined)

        ENV.fetch('JEKYLL_DATA_DIR', default_value)
      end
    end
  end
end
