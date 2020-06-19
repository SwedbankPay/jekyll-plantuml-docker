require "jekyll"
require_relative "argument-parser"
require_relative "command-line-argument-error"
require_relative "string-bold"
require_relative "commands/deployer"
require_relative "commands/verifier"
require_relative "commands/jekyll-commander"

module Jekyll::PlantUml
  class Commander
    def initialize(jekyll_env, jekyll_data_dir, jekyll_var_dir, docker_image_name, docker_image_version)
      @argument_parser = ArgumentParser.new(docker_image_name, docker_image_version)
      @jekyll_config_provider = JekyllConfigProvider.new(jekyll_data_dir)
      @jekyll_var_dir = jekyll_var_dir
      @jekyll_env = jekyll_env
    end

    def execute(args = nil)
      begin
        parsed_args = @argument_parser.parse(args)
        execute_args(parsed_args)
      rescue Docopt::Exit => e
        puts e.message
      rescue CommandLineArgumentError => e
        puts "Error! #{e}.".bold
        puts ""
        puts @argument_parser.help
        exit 1
      end
    end

    private

    def execute_args(args)
      command = args["<command>"]
      jekyll_config = @jekyll_config_provider.get_config(command)

      case command
      when "deploy"
        dry_run = args["--dry-run"]
        verify = args["--verify"]
        deployer = Deployer.new(jekyll_config, @jekyll_var_dir)
        deployer.deploy(dry_run, verify)
      when "build", "serve"
        if args["--dry-run"]
          puts "Warning: --dry-run has no effect on the `jekyll #{command}` command."
        end

        jekyll_commander = JekyllCommander.new(jekyll_config)
        jekyll_commander.execute(command)
      else
        raise CommandLineArgumentError.new("Unknown command '#{command}'")
      end

      if args["--verify"]
        verifier = Verifier.new(jekyll_config)
        verifier.verify
      end
    end
  end
end
