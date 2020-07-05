# frozen_string_literal: true

module Jekyll
  module PlantUml
    module Specs
      module Helpers
        # A spec implementation of the Jekyll::PlantUml::Commands::JekyllBuilder
        # classes, used for testing.
        class SpecJekyllBuilder
          attr_writer :logger
          
          def initialize(_, _); end
          def execute; end
        end
      end
    end
  end
end
