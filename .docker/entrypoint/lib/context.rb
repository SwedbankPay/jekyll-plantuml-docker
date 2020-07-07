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

      def initialize(env, var_dir, data_dir, auth_token = nil, debug = false)
        env.must_be_a! :non_empty, String
        var_dir.must_be_a! :non_empty, String
        data_dir.must_be_a! :non_empty, String

        @env = env
        @var_dir = var_dir
        @data_dir = data_dir
        @debug = debug
        @auth_token = auth_token
        @arguments = Arguments.default
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
    end
  end
end
