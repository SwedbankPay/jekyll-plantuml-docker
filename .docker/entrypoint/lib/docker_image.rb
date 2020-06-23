# frozen_string_literal: true

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::DockerImage class provides data for the
    # jekyll-plantuml Docker image.
    class DockerImage
      attr_reader :name
      attr_reader :tag
      attr_reader :version
      attr_reader :fqn

      def initialize(name, tag, version)
        raise ArgumentError, 'name is nil' if name.nil?
        raise ArgumentError, 'tag is nil' if tag.nil?
        raise ArgumentError, 'version is nil' if version.nil?

        @name = name
        @tag = tag
        @version = version
        @fqn = "#{name}:#{tag}"
      end

      def to_s
        @fqn
      end
    end
  end
end
