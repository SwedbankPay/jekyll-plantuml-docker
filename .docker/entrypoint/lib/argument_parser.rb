# frozen_string_literal: true

require 'docopt'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::ArgumentParser class parses arguments with Docopt
    # and exposes its help and usage command line screens.
    class ArgumentParser
      def initialize(docker_image)
        @docker_image_version = docker_image.version
        @doc = <<~DOCOPT
          Runs the #{docker_image.name} container's entrypoint.

          Usage:
            #{docker_image.fqn} [-h | --help] [--version] <command> [--dry-run] [--verify]

          Options:
            -h --help     Print this screen.
            --version     Print the version of #{docker_image.name}.
            --dry-run     On a dry-run, the the deploy command will not push the changes
                          to the remote `origin`.
            --verify      Verifies the built output before deploying. Can be used in
                          combination with --dry-run in tests and for local debugging.

          Commands:
            deploy        Builds the website with `jekyll build` and then deploys
                          it to a branch (default `gh-pages`) and pushes it to the remote
                          `origin`.
            build         Executes the `jekyll build` command.
            serve         Executes the `jekyll serve` command.
        DOCOPT
      end

      def parse(args = nil)
        params = { version: @docker_image_version }
        params[:argv] = args if args
        Docopt.docopt(@doc, params)
      end

      def help
        @doc
      end

      def usage
        Docopt.printable_usage(@doc)
      end
    end
  end
end
