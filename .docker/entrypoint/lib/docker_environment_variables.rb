# frozen_string_literal: true

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::DockerEnvironmentVariables class provides environment
    # variables for building of the Docker container.
    class DockerEnvironmentVariables
      attr_reader :image_name, :image_tag, :image_version

      def initialize
        @image_name = ENV.fetch('DOCKER_IMAGE_NAME')
        @image_tag = ENV.fetch('DOCKER_IMAGE_TAG')
        @image_version = ENV.fetch('DOCKER_IMAGE_VERSION')
      end
    end
  end
end
