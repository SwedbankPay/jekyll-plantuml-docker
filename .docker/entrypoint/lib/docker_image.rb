# frozen_string_literal: true

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::DockerImage class provides data for the
    # jekyll-plantuml Docker image.
    class DockerImage
      attr_reader :name, :tag, :version, :fqn

      def initialize(name, tag, version)
        name.must_be_a! :non_empty, String
        tag.must_be_a! :non_empty, String
        version.must_be_a! :non_empty, String

        @name = name
        @tag = tag
        @version = version
        @fqn = "#{name}:#{tag}"
      end

      def self.from_environment
        env = EnvironmentVariables.new
        new(env.docker.image_name, env.docker.image_tag, env.docker.image_version)
      end

      def to_s
        @fqn
      end
    end
  end
end
