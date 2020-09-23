# frozen_string_literal: true

require 'jekyll'
require 'html-proofer'
require 'html-proofer-unrendered-markdown'
require 'concurrent'
require_relative '../context'
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
        attr_accessor :html_proofer, :logger

        def initialize(context)
          context.must_be_a! Context

          @context = context
          conf = @context.configuration
          @jekyll_destination_dir = conf.value_for('destination')
          @jekyll_destination_dir.must_be_a_directory!
          @html_proofer = HTMLProofer
        end

        def verify
          ensure_directory_not_empty!(@jekyll_destination_dir)

          opts = options(@context.arguments.ignore_urls)

          log(:debug, "Checking '#{@jekyll_destination_dir}' with HTMLProofer")
          log(:debug, opts)

          proofer = @html_proofer.check_directory(@jekyll_destination_dir, opts)
          proofer.before_request { |request| before_request(request) }
          proofer.run
        end

        private

        def before_request(request)
          uri = URI(request.base_url)
          return unless uri.host.match('github\.(com|io)$')

          auth = "Bearer #{@context.auth_token}"
          log(:debug, 'Setting Bearer Token for GitHub request')
          request.options[:headers]['Authorization'] = auth
        end

        def ensure_directory_not_empty!(dir)
          html_glob = File.join(dir, '**/*.html')
          raise "#{dir} contains no .html files" if Dir.glob(html_glob).empty?
        end

        def options(ignore_urls = nil)
          ignore_urls = massage(ignore_urls)

          opts = default_options
          log_level = @context.arguments.log_level
          opts[:log_level] = ":#{log_level}" unless log_level.nil?
          opts[:url_ignore] = ignore_urls if ignore_urls.valid_array?

          opts
        end

        def default_options
          {
            assume_extension: true,
            check_html: true,
            #check_favicon: true,
            #check_opengraph: true,
            enforce_https: true,
            only_4xx: true,
            check_unrendered_link: true,
            report_mismatched_tags: true,
            #parallel: { in_processes: Concurrent.processor_count },
            typheous: {
              verbose: @context.verbose?
            },
            verbose: @context.verbose?,
            cache: {
              timeframe: '1h'
            },
            checks_to_ignore: ['opengraphcheck', 'scriptcheck', 'chercker']
          }
        end

        def massage(urls)
          return [urls] if urls.is_a?(Regexp) || urls.is_a?(String)
          return nil unless urls.valid_array?

          urls.map { |url| convert_to_regex(url) }
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

        def log(severity, message)
          (@logger ||= Jekyll.logger).public_send(
            severity,
            "   jekyll-plantuml: #{message}"
          )
        end
      end
    end
  end
end
