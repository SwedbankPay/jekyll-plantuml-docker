# frozen_string_literal: true

require 'jekyll'
require_relative 'arguments'
require_relative 'extensions/object_extensions'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::Context class provides data from and about the
    # execution environment
    class Context
      attr_reader :env
      attr_reader :var_dir
      attr_reader :data_dir
      attr_reader :debug
      attr_reader :auth_token
      attr_reader :configuration
      attr_reader :arguments
      attr_reader :git_branch
      attr_reader :git_repository_url

      def initialize(env, var_dir, data_dir, auth_token: nil, git_branch: nil, git_repository_url: nil, debug: false)
        env.must_be_a! :non_empty, String
        var_dir.must_be_a! :non_empty, String
        data_dir.must_be_a! :non_empty, String

        @env = env
        @var_dir = var_dir
        @data_dir = data_dir
        @auth_token = auth_token
        @git_branch = git_branch
        @git_repository_url = git_repository_url
        @debug = debug
        @arguments = Arguments.default
      end

      def self.from_environment
        env = ENV.fetch('JEKYLL_ENV', 'production')
        data_dir = ENV.fetch('JEKYLL_DATA_DIR', Dir.pwd)
        var_dir = ENV.fetch('JEKYLL_VAR_DIR')
        auth_token = ENV.fetch('JEKYLL_GITHUB_TOKEN', nil) || ENV.fetch('GITHUB_TOKEN', nil)
        git_branch = ENV.fetch('GITHUB_BRANCH', nil)
        git_repository_url = ENV.fetch('GITHUB_REPOSITORY_URL', nil)
        debug = ENV.fetch('DEBUG', false)

        self.new(
          env,
          var_dir,
          data_dir,
          auth_token: auth_token,
          git_branch: git_branch,
          git_repository_url: git_repository_url,
          debug: debug)
      end

      def configuration=(config)
        config.must_be_a! :non_empty, Jekyll::Configuration
        @configuration = config
      end

      def arguments=(args)
        args.must_be_a! Arguments
        @arguments = args
      end

      def verbose?
        @debug || arguments.log_level == :debug
      end

      def profile?
        @arguments.profile?
      end
    end
  end
end
