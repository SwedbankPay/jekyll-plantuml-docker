# frozen_string_literal: true

require 'jekyll'
require 'html-proofer'
require 'html-proofer-unrendered-markdown'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::Commands module contains the implementations of the
    # various commands that Jekyll PlantUML supports.
    module Commands
      # The Jekyll::PlantUml::Verifier class executes HTMLProofer on a built
      # Jekyll site in order to verify that the HTML is correct.
      class Verifier
        def initialize(jekyll_config)
          raise 'Nil or empty Jekyll config' if jekyll_config.nil? || jekyll_config.empty?
          raise "No 'destination' key found in the Jekyll config" unless jekyll_config.key? 'destination'

          @jekyll_destination_dir = jekyll_config['destination']
          raise "#{@jekyll_destination_dir} does not exist" unless Dir.exist?(@jekyll_destination_dir)
        end

        def verify
          html_glob = File.join(@jekyll_destination_dir, '**/*.html')

          raise "#{@jekyll_destination_dir} contains no .html files" if Dir.glob(html_glob).empty?

          options = {
            assume_extension: true,
            check_html: true,
            enforce_https: true,
            only_4xx: true,
            check_unrendered_link: true
          }

          HTMLProofer.check_directory(@jekyll_destination_dir, options).run
        end
      end
    end
  end
end
