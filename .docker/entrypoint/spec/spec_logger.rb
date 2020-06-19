module Jekyll
  module PlantUml
    class SpecLogger
      attr_reader :level

      def initialize(only_log_level = nil)
        @only_log_level = only_log_level
      end

      def level=(level)
        @level = level
      end

      def public_send(level_of_message, message)
        return if @only_log_level && @only_log_level != level_of_message

        @message ||= ""
        @message << message
      end

      def message
        @message
      end
    end
  end
end
