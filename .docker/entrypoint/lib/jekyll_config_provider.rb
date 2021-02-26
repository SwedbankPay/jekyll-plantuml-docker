# frozen_string_literal: true

require 'jekyll'
require_relative 'git_metadata_provider'
require_relative 'extensions/object_extensions'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::JekyllConfigProvider class provides Jekyll
    # configuration by probing for `_config.yml` files and setting configuration
    # values to meaningful values that should ensure a well built Jekyll site.
    class JekyllConfigProvider
      def initialize(context)
        context.must_be_a! Context

        @git = GitMetadataProvider.new(context)
        @context = context
      end

      def provide(jekyll_command)
        config_file_path = config_file_path()
        config(jekyll_command, config_file_path)
      end

      private

      def log(severity, message)
        (@logger ||= Jekyll.logger).public_send(
          severity,
          "   jekyll-plantuml: #{message}"
        )
      end

      def config_file_path
        config_file_path = File.join(@context.data_dir, '_config.yml')

        unless File.file?(config_file_path)
          default_config_file_path = File.join(__dir__, '..', '_config.default.yml')
          default_config_file_path = File.expand_path(default_config_file_path)
          log(:info, "No _config.yml found. Using default: #{default_config_file_path}")
          config_file_path = default_config_file_path
        end

        config_file_path
      end

      def config(jekyll_command, config_file_path)
        raise ArgumentError, 'jekyll_command is nil' if jekyll_command.nil?

        jekyll_config = Jekyll.configuration(default_config(config_file_path))
        jekyll_config = jekyll_config.merge(serve_config) if jekyll_command == 'serve'
        jekyll_config['verbose'] = true if @context.verbose?
        jekyll_config['profile'] = true if @context.profile?
        jekyll_config['github'] = github_config(jekyll_config)

        jekyll_config
      end

      def default_config(config_file_path)
        cfg = {
          'config' => config_file_path,
          'incremental' => true,
          'source' => @context.data_dir,
          'destination' => File.join(@context.data_dir, '_site')
        }
        cfg['url'] = @context.arguments.site_url unless @context.arguments.site_url.nil?
        cfg
      end

      def serve_config
        {
          'host' => '0.0.0.0',
          'port' => '4000',
          'livereload_port' => 35_729,
          'livereload' => true,
          'force_polling' => true,
          'watch' => true,
          'serving' => true
        }
      end

      def github_config(jekyll_config)
        cfg = jekyll_config['github'] || {}
        cfg['branch'] = @git.branch unless @git.branch.nil?
        repository_url = find_repository_url(jekyll_config)

        if repository_url.nil?
          log(:debug, 'No repository_url found.')
        else
          log(:debug, "Setting site.github.repository_url to <#{repository_url}>.")
          cfg['repository_url'] = repository_url
        end

        cfg
      end

      def find_repository_url(jekyll_config)
        return @git.repository_url unless @git.repository_url.nil? || @git.repository_url.empty?

        repository_url = jekyll_config['repository']
        unless repository_url.nil? || repository_url.start_with?('https://') || repository_url.start_with?('http://')
          repository_url = "https://github.com/#{repository_url}"
        end

        repository_url
      end
    end
  end
end
