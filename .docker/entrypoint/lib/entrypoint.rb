require_relative "jekyll-exec"

module Jekyll::PlantUml
  class Entrypoint
    def initialize
      @jekyll_env = ENV.fetch("JEKYLL_ENV", "production")
      @docker_image_name = ENV.fetch("DOCKER_IMAGE_NAME")
      @docker_image_version = ENV.fetch("DOCKER_IMAGE_VERSION")
    end

    def execute
      entrypoint = JekyllExec.new(@jekyll_env, @docker_image_name, @docker_image_version)
      entrypoint.execute
    end
  end
end

Jekyll::PlantUml::Entrypoint.new.execute
