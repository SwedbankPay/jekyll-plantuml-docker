# frozen_string_literal: true

require 'docopt'
require_relative 'arguments'
require_relative 'extensions/object_extensions'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::ArgumentParser class parses arguments with Docopt
    # and exposes its help and usage command line screens.
    class ArgumentParser
      def initialize(docker_image)
        docker_image.must_be_a! DockerImage

        @docker_image_version = docker_image.version
        # rubocop:disable Layout/HeredocIndentation,Layout/ClosingHeredocIndentation
        @doc = <<~DOCOPT
Runs the #{docker_image.name} container's entrypoint.

Usage:
  #{docker_image.fqn} [-h | --help]
  #{docker_image.fqn} [--version]
  #{docker_image.fqn} build [--env=env] [--log-level=level] [--verify] [--ignore-url=url ...] [--profile]
  #{docker_image.fqn} serve [--env=env] [--log-level=level] [--verify] [--ignore-url=url ...] [--profile]
  #{docker_image.fqn} deploy [--env=env] [--log-level=level] [--dry-run] [--verify] [--ignore-url=url ...] [--profile]

Options:
  -h --help           Print this screen.
  --version           Print the version of #{docker_image.name}.
  --env=env           Set the environment Jekyll should build for. Should be set
                      to 'production' when the command is 'deploy'. Will default
                      to 'development' if not set.
  --log-level=level   The level that should be visible in log output. Default 'info'.
  --dry-run           On a dry-run, the the deploy command will not push the
                      changes to the remote `origin`.
  --verify            Verifies the built output before deploying. Can be used in
                      combination with --dry-run in tests and for local debugging.
  --ignore-url=url    Ignores the specified URL when doing --verify.
  --profile           Enables the Liquid Profiler

Commands:
  deploy        Builds the website with `jekyll build` and then deploys
                it to a branch (default `gh-pages`) and pushes it to the remote
                `origin`.
  build         Executes the `jekyll build` command.
  serve         Executes the `jekyll serve` command.
DOCOPT
        # rubocop:enable Layout/HeredocIndentation,Layout/ClosingHeredocIndentation
      end

      def parse(args = nil)
        params = { version: @docker_image_version }
        params[:argv] = args if args
        options = Docopt.docopt(@doc, params)
        Arguments.new(options)
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
