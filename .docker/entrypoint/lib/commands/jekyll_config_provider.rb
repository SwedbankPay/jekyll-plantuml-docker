# frozen_string_literal: true

require 'jekyll'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::JekyllConfigProvider class provides Jekyll
    # configuration by probing for `_config.yml` files and setting configuration
    # values to meaningful values that should ensure a well built Jekyll site.
    class JekyllConfigProvider
      def initialize(jekyll_data_dir)
        @jekyll_data_dir = jekyll_data_dir
      end

      def get_config(jekyll_command)
        config_file_path = config_file_path()
        jekyll_config = config(jekyll_command, config_file_path)

        begin
          pages_html_url = pages_html_url
          log(:info, "Setting site.url to <#{pages_html_url}>.")
          jekyll_config.merge({ 'url' => pages_html_url })
        rescue StandardError => e
          unable_to_retrieve_github_metadata(e)
        end

        jekyll_config
      end

      private

      def unable_to_retrieve_github_metadata(error)
        log(:error, 'Unable to retrieve GitHub metadata. URLs may be wrong in the resulting HTML.')
        log(:error, 'Defining the JEKYLL_GITHUB_TOKEN environment variable may help.')
        log(:error, 'See the following issue for details: https://github.com/github/pages-gem/issues/399')
        log(:error, error)
      end

      def log(severity, message)
        (@logger ||= Jekyll.logger).public_send(severity, "jekyll-plantuml: #{message}")
      end

      def config_file_path
        config_file_path = File.join(@jekyll_data_dir, '_config.yml')

        unless File.file?(config_file_path)
          default_config_file_path = File.join(__dir__, '..', '..', '_config.default.yml')
          default_config_file_path = File.expand_path(default_config_file_path)
          log(:info, "No _config.yml found. Using default: #{default_config_file_path}")
          config_file_path = default_config_file_path
        end

        config_file_path
      end

      def config(jekyll_command, config_file_path)
        jekyll_config = Jekyll.configuration(default_config(config_file_path))
        jekyll_config.merge(serve_config) if jekyll_command == 'serve'
        jekyll_config
      end

      def default_config(config_file_path)
        {
          'config' => config_file_path,
          'incremental' => true,
          'base_url' => '',
          'source' => @jekyll_data_dir,
          'destination' => File.join(@jekyll_data_dir, '_site')
        }
      end

      def serve_config
        {
          'host' => '0.0.0.0',
          'port' => '4000',
          'livereload' => true,
          'force_polling' => true,
          'watch' => true
        }
      end

      def pages_html_url
        ghm = Jekyll::GitHubMetadata
        ghm.site = Jekyll::Site.new(jekyll_config)
        gh_client = Jekyll::GitHubMetadata::Client.new
        pages = gh_client.pages(ghm.repository.nwo)
        pages.html_url
      end
    end
  end
end
