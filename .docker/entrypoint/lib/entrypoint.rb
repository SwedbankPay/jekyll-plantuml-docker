# frozen_string_literal: true

require_relative 'commander'
require_relative 'context'
require_relative 'docker_image'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::Entrypoint class is responsible for bootstrapping
    # the Ruby application exposed through the jekyll-plantuml Docker container.
    class Entrypoint
      def initialize(context = nil, docker_image = nil)
        @context = initialize_context(context)
        @docker_image = initialize_docker_image(docker_image)
      end

      def execute
        commander = Commander.new(@context, @docker_image)
        commander.execute
      end

      private

      def initialize_context(context)
        return context unless context.nil?

        Context.from_environment
      end

      def initialize_docker_image(docker_image)
        return docker_image unless docker_image.nil?

        DockerImage.from_environment
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  # We set STDOUT.sync to avoid buffering when running in docker-compose
  $stdout.sync = true
  # This will only run if the script was the main, not loaded or required
  Jekyll::PlantUml::Entrypoint.new.execute
end
