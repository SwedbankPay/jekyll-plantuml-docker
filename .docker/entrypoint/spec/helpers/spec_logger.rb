# frozen_string_literal: false

module Jekyll
  module PlantUml
    module Specs
      module Helpers
        # SpecLogger is used to capture log statements for testing
        class SpecLogger
          attr_accessor :level
          attr_reader :message

          def initialize(*levels)
            @message = ''
            @levels = levels
          end

          def public_send(level_of_message, message)
            return if @levels && !@levels.include?(level_of_message)

            @message ||= ''
            @message << message
          end
        end
      end
    end
  end
end
