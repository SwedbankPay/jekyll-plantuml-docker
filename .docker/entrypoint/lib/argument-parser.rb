require "docopt"

module Jekyll::PlantUml
  class ArgumentParser
    def initialize(docker_image_name, docker_image_version)
      @docker_image_version = docker_image_version
      docker_image_fqn = "#{docker_image_name}:#{docker_image_version}"
      @doc = <<DOCOPT
Runs the #{docker_image_name} container's entrypoint.

Usage:
  #{docker_image_fqn} [-h | --help] [--version]
                      <command> [--dry-run] [--verify]
                      [<jekyll-command>]

Options:
  -h --help     Print this screen.
  --version     Print the version of #{docker_image_name}.
  --dry-run     On a dry-run, the the deploy command will not push the changes
                to the remote `origin`.
  --verify      Verifies the built output before deploying. Can be used in
                combination with --dry-run in tests and for local debugging.

Commands:
  deploy        Builds the website with `jekyll build` and then deploys
                it to a branch and pushes it to the remote `origin`.
  jekyll        Executes the following Jekyll command.
DOCOPT
    end

    def parse
      Docopt.docopt(@doc, { :version => @docker_image_version })
    end

    def help
      @doc
    end

    def usage
      Docopt.printable_usage(@doc)
    end
  end
end
