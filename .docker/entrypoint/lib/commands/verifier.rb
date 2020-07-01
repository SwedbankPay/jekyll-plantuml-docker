# frozen_string_literal: true

require 'jekyll'
require 'html-proofer'
require 'html-proofer-unrendered-markdown'
require_relative '../file_not_found_error'

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
          raise ArgumentError, 'jekyll_config cannot be nil' if jekyll_config.nil?
          raise ArgumentError, 'jekyll_config must be a hash' unless jekyll_config.is_a? Hash
          raise ArgumentError, 'jekyll_config cannot be empty' if jekyll_config.empty?
          raise ArgumentError, "No 'destination' key found in the Jekyll config" unless jekyll_config.key? 'destination'

          @jekyll_destination_dir = jekyll_config['destination']
          @log_level = jekyll_config[:level] || jekyll_config['level']

          unless Dir.exist?(@jekyll_destination_dir)
            raise Jekyll::PlantUml::FileNotFoundError, "#{@jekyll_destination_dir} does not exist"
          end
        end

        def verify(ignore_urls = nil)
          html_glob = File.join(@jekyll_destination_dir, '**/*.html')

          raise "#{@jekyll_destination_dir} contains no .html files" if Dir.glob(html_glob).empty?

          opts = options(ignore_urls)

          HTMLProofer.check_directory(@jekyll_destination_dir, opts).run
        end

        private

        def options(ignore_urls = nil)
          opts = {
            assume_extension: true,
            check_html: true,
            enforce_https: true,
            only_4xx: true,
            check_unrendered_link: true
          }

          opts[:log_level] = @log_level.to_sym unless @log_level.nil?
          opts[:url_ignore] = ignore_urls if valid_array? ignore_urls

          opts
        end

        def valid_array?(obj)
          !obj.nil? && obj.is_a?(Array) && !obj.empty?
        end
      end
    end
  end
end
