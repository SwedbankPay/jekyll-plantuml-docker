# frozen_string_literal: true

require 'jekyll'
require 'html-proofer'
require 'html-proofer-unrendered-markdown'
require_relative '../extensions/object_extensions'

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
          @jekyll_destination_dir = jekyll_config.value_for('destination')
          @log_level = jekyll_config[:level] || jekyll_config['level']
          @jekyll_destination_dir.must_be_a_directory!
        end

        def verify(ignore_urls = nil)
          html_glob = File.join(@jekyll_destination_dir, '**/*.html')

          raise "#{@jekyll_destination_dir} contains no .html files" if Dir.glob(html_glob).empty?

          opts = options(ignore_urls)

          HTMLProofer.check_directory(@jekyll_destination_dir, opts).run
        end

        private

        def options(ignore_urls = nil)
          ignore_urls = massage(ignore_urls)

          opts = default_options
          opts[:log_level] = @log_level.to_sym unless @log_level.nil?
          opts[:url_ignore] = ignore_urls if ignore_urls.valid_array?

          opts
        end

        def default_options
          {
            assume_extension: true,
            check_html: true,
            enforce_https: true,
            only_4xx: true,
            check_unrendered_link: true
          }
        end

        def massage(ignore_urls)
          return [ignore_urls] if ignore_urls.is_a?(Regexp) || ignore_urls.is_a?(String)
          return nil unless ignore_urls.valid_array?

          ignore_urls.map { |url| convert_to_regex(url) }
        end

        def convert_to_regex(value)
          return value if value.is_a? Regexp
          return value unless value.is_a? String

          if value.start_with?('%r{') && value.end_with?('}')
            regexp = value[3...-1]
            return Regexp.new(regexp)
          end

          value
        end
      end
    end
  end
end
