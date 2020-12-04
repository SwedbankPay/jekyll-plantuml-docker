# frozen_string_literal: true

require 'jekyll'
require_relative 'arguments'
require_relative 'environment_variables'
require_relative 'extensions/object_extensions'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::Context class provides data from and about the
    # execution environment
    class Context
      attr_reader :env, :var_dir, :data_dir, :configuration, :arguments
      attr_accessor :auth_token, :git_branch, :git_repository_url, :debug

      def initialize(env, var_dir, data_dir)
        env.must_be_a! :non_empty, String
        var_dir.must_be_a! :non_empty, String
        data_dir.must_be_a! :non_empty, String

        @env = env
        @var_dir = var_dir
        @data_dir = data_dir
        @debug = false
        @arguments = Arguments.default
      end

      def self.from_environment
        env = EnvironmentVariables.new
        context = new(env.env, env.var_dir, env.data_dir)
        context.debug = env.debug
        context.auth_token = env.auth_token
        context.git_branch = env.git_branch
        context.git_repository_url = env.git_repository_url
        context
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
