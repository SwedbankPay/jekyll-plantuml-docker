# frozen_string_literal: true

require_relative 'commander'
require_relative 'jekyll_environment'
require_relative 'docker_image'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::Entrypoint class is responsible for bootstrapping
    # the Ruby application exposed through the jekyll-plantuml Docker container.
    class Entrypoint
      def initialize(jekyll_env = nil, docker_image = nil)
        @jekyll_env = initialize_jekyll_env(jekyll_env)
        @docker_image = initialize_docker_image(docker_image)
      end

      def execute
        commander = Commander.new(@jekyll_env, @docker_image)
        commander.execute
      end

      private

      def initialize_jekyll_env(jekyll_env)
        return jekyll_env unless jekyll_env.nil?

        env = ENV.fetch('JEKYLL_ENV', 'production')
        jekyll_data_dir = ENV.fetch('JEKYLL_DATA_DIR', Dir.pwd)
        jekyll_var_dir = ENV.fetch('JEKYLL_VAR_DIR')
        debug = ENV.fetch('DEBUG', false)

        JekyllEnvironment.new(env, jekyll_var_dir, jekyll_data_dir, debug)
      end

      def initialize_docker_image(docker_image)
        return docker_image unless docker_image.nil?

        docker_image_name = ENV.fetch('DOCKER_IMAGE_NAME')
        docker_image_tag = ENV.fetch('DOCKER_IMAGE_TAG')
        docker_image_version = ENV.fetch('DOCKER_IMAGE_VERSION')

        DockerImage.new(docker_image_name, docker_image_tag, docker_image_version)
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  # We set STDOUT.sync to avoid buffering when running in docker-compose
  STDOUT.sync = true
  # This will only run if the script was the main, not loaded or required
  Jekyll::PlantUml::Entrypoint.new.execute
end
