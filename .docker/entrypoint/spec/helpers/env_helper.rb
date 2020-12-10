# frozen_string_literal: false

module Jekyll
  module PlantUml
    class EnvHelper
      attr_reader :log

      def initialize
        @old_environment_variables = {}
      end

      def env(environment_variables)
        @new_environment_variables = environment_variables
        environment_variables.each do |key, value|
          old_value = ENV.has_key?(key) ? ENV.fetch(key) : :undefined
          @old_environment_variables[key] = old_value

          set_value(key, value)
        end
      end

      def finalize
        @old_environment_variables.each do |key, value|
          set_value(key, value)
        end
      end

      private

      def set_value(key, value)
        if (value == :undefined)
          ENV.delete(key) if ENV.has_key?(key)
        else
          ENV[key] = value.to_s
        end
      end
    end
  end
end
