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

      def initialize
        @env = ENV.fetch('JEKYLL_ENV', 'production')
        @data_dir = ENV.fetch('JEKYLL_DATA_DIR', Dir.pwd)
        @var_dir = ENV.fetch('JEKYLL_VAR_DIR')
        @auth_token = ENV.fetch('JEKYLL_GITHUB_TOKEN', nil) || ENV.fetch('GITHUB_TOKEN', nil)
        @git_branch = ENV.fetch('GITHUB_BRANCH', nil)
        @git_repository_url = ENV.fetch('GITHUB_REPOSITORY_URL', nil)
        @debug = ENV.fetch('DEBUG', false)
      end
    end
  end
end
