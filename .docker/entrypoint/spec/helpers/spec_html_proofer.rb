# frozen_string_literal: true

module Jekyll
  module PlantUml
    module Specs
      module Helpers
        # A spec implementation of the Jekyll::PlantUml::Commands::JekyllBuilder
        # classes, used for testing.
        class SpecHTMLProofer
          def self.check_directory(_, _)
            SpecHTMLProofer.new
          end

          def run; end
        end
      end
    end
  end
end
