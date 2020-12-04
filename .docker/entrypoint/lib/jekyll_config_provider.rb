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
        jekyll_config['github'] = jekyll_config['github'] || {}
        jekyll_config['github']['branch'] = @git.branch unless @git.branch.nil?
        jekyll_config['github']['repository_url'] = @git.repository_url unless @git.repository_url.nil?

        jekyll_config
      end

      def default_config(config_file_path)
        {
          'config' => config_file_path,
          'incremental' => true,
          'source' => @context.data_dir,
          'destination' => File.join(@context.data_dir, '_site')
        }
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
    end
  end
end
