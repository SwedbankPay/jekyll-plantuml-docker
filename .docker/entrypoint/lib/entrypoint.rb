# frozen_string_literal: true

require_relative 'commander'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::Entrypoint class is responsible for bootstrapping
    # the Ruby application exposed through the jekyll-plantuml Docker container.
    class Entrypoint
      def initialize
        @jekyll_env = ENV.fetch('JEKYLL_ENV', 'production')
        @jekyll_data_dir = ENV.fetch('JEKYLL_DATA_DIR', Dir.pwd)
        @jekyll_var_dir = ENV.fetch('JEKYLL_VAR_DIR')
        @docker_image_name = ENV.fetch('DOCKER_IMAGE_NAME')
        @docker_image_tag = ENV.fetch('DOCKER_IMAGE_TAG')
        @docker_image_version = ENV.fetch('DOCKER_IMAGE_VERSION')

        raise "#{@jekyll_data_dir} does not exist" unless Dir.exist? @jekyll_data_dir
      end

      def execute
        commander = Commander.new(@jekyll_env, @jekyll_data_dir, @jekyll_var_dir, @docker_image_name, @docker_image_tag, @docker_image_version)
        commander.execute
      end
    end
  end
end

Jekyll::PlantUml::Entrypoint.new.execute
