# frozen_string_literal: true

require_relative 'extensions/object_extensions'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::ExecEnv class provides data from and about the
    # execution environment
    class ExecEnv
      attr_reader :env
      attr_reader :var_dir
      attr_reader :data_dir
      attr_reader :debug

      def initialize(env, var_dir, data_dir, debug = false)
        env.must_be_a! :non_empty, String
        var_dir.must_be_a! :non_empty, String
        data_dir.must_be_a! :non_empty, String

        @env = env
        @var_dir = var_dir
        @data_dir = data_dir
        @debug = debug
      end
    end
  end
end
