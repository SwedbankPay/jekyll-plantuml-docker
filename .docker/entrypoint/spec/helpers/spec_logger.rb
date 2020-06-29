# frozen_string_literal: false

module Jekyll
  module PlantUml
    class SpecLogger
      attr_reader :level

      def initialize(only_log_level = nil)
        @only_log_level = only_log_level
      end

      attr_writer :level

      def public_send(level_of_message, message)
        return if @only_log_level && @only_log_level != level_of_message

        @message ||= ''
        @message << message
      end

      attr_reader :message
    end
  end
end
