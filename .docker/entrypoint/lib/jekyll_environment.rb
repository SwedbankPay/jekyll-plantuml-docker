# frozen_string_literal: true

require_relative 'extensions/object_extensions'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::JekyllEnvironment class provides
    # environment-specific data for Jekyll.
    class JekyllEnvironment
      attr_reader :env
      attr_reader :var_dir
      attr_reader :data_dir
      attr_reader :debug

      def initialize(env, var_dir, data_dir, debug = false)
        raise ArgumentError, 'env is nil' if env.nil?
        raise ArgumentError, 'data_dir is nil' if data_dir.nil?
        raise ArgumentError, 'var_dir is nil' if var_dir.nil?

        @env = env
        @var_dir = var_dir
        @data_dir = data_dir
        @debug = debug
      end
    end
  end
end
