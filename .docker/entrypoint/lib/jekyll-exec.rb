require "jekyll"
require "jekyll-github-metadata"
require_relative "argument-parser"
require_relative "command-line-argument-error"
require_relative "string-bold"

module Jekyll::PlantUml
  class JekyllExec
    def initialize(jekyll_env, docker_image_name, docker_image_version)
      @argument_parser = ArgumentParser.new(docker_image_name, docker_image_version)
      @jekyll_env = jekyll_env
    end

    def execute
      begin
        args = @argument_parser.parse
        # puts args
        execute_args(args)
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
      case command
      when "deploy"
        dry_run = args["--dry-run"]
        verify = args["--verify"]
        execute_deploy(dry_run, verify)
      when "jekyll"
        jekyll_command = args["<jekyll-command>"]
        execute_jekyll_command(jekyll_command)
      else
        raise CommandLineArgumentError.new("Unknown command '#{command}'")
      end
    end

    def execute_deploy(dry_run, verify)
      message = "Deploying"
      deploy_cmd = "/usr/jekyll/bin/deploy.sh --verbose"

      if verify
        message << ", verified"
        deploy_cmd << " --verify"
      end

      if dry_run
        message << ", dry-run"
        deploy_cmd << " --dry-run"
      end

      message << "…"

      puts message

      jekyll_config = get_config("deploy")
      Jekyll::Commands::Build.process(jekyll_config)
      exec(deploy_cmd)
    end

    def execute_jekyll_command(requested_jekyll_command)
      jekyll_command_class = nil
      jekyll_command = requested_jekyll_command.downcase

      case jekyll_command
      when "build"
        jekyll_command_class = Jekyll::Commands::Build
      when "serve"
        jekyll_command_class = Jekyll::Commands::Serve
      else
        raise CommandLineArgumentError.new("Unsupported Jekyll command '#{requested_jekyll_command}'")
      end

      jekyll_config = get_config(jekyll_command)
      jekyll_command_class.process(jekyll_config)
    end

    def get_config(command)
      config_file_path = File.join(Dir.pwd, "_config.yml")

      unless File.file?(config_file_path)
        default_config_file_path = File.join(__dir__, "..", "_config.default.yml")
        puts "No _config.yml found. Using default: #{default_config_file_path}"
        config_file_path = default_config_file_path
      end

      jekyll_config = Jekyll.configuration({
        "config" => config_file_path,
        "incremental" => true,
        "base_url" => "",
      })

      begin
        ghm = Jekyll::GitHubMetadata
        ghm.site = Jekyll::Site.new(jekyll_config)
        gh_client = Jekyll::GitHubMetadata::Client.new
        pages = gh_client.pages(ghm.repository.nwo)

        puts "Setting site.url to <#{pages.html_url}>."

        jekyll_config.merge({
          "url" => pages.html_url,
        })
      rescue => exception
        puts "Unable to retrieve GitHub metadata. URLs may be wrong in the resulting HTML."
        puts "Defining the JEKYLL_GITHUB_TOKEN environment variable may help. See the following issue for details:"
        puts "https://github.com/github/pages-gem/issues/399#issuecomment-450799841"
        puts exception
      end

      if command == "serve"
        jekyll_config.merge({
          "host" => "0.0.0.0",
          "port" => "4000",
          "livereload" => true,
          "force_polling" => true,
          "watch" => true,
        })
      end

      jekyll_config
    end
  end
end
