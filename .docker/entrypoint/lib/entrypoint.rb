require_relative "jekyll-exec"

module Jekyll::PlantUml
  class Entrypoint
    def initialize
      @jekyll_env = ENV.fetch("JEKYLL_ENV", "production")
      @jekyll_var_dir = ENV.fetch("JEKYLL_VAR_DIR")
      @docker_image_name = ENV.fetch("DOCKER_IMAGE_NAME")
      @docker_image_version = ENV.fetch("VERSION")
    end

    def execute
      entrypoint = JekyllExec.new(@jekyll_env, @jekyll_var_dir, @docker_image_name, @docker_image_version)
      entrypoint.execute
    end
  end
end

Jekyll::PlantUml::Entrypoint.new.execute
