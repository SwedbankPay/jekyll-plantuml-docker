require "jekyll"
require "jekyll-github-metadata"

module Jekyll::PlantUml
  class Entrypoint
    def initialize
      @jekyll_var_dir = ENV.fetch("JEKYLL_VAR_DIR")
      @jekyll_env = ENV.fetch("JEKYLL_ENV", "production")
    end

    def execute
      if ARGV.length == 0
        execute_default()
      elsif ARGV[0] == "deploy"
        execute_deploy()
      elsif ARGV[0] == "jekyll"
        execute_jekyll_command(ARGV[1])
      else
        execute_unknown()
      end
    end

    private

    def execute_default
      puts "Running default command 'jekyll serve' (env: #{@jekyll_env})..."
      jekyll_config = get_config("serve")
      Jekyll::Commands::Serve.process(jekyll_config)
    end

    def execute_deploy
      puts "Deploying..."
      jekyll_config = get_config("deploy")
      Jekyll::Commands::Build.process(jekyll_config)
      exec("/usr/jekyll/bin/deploy.sh --verbose")
    end

    def execute_jekyll_command(requested_jekyll_command)
      if requested_jekyll_command.empty?
        raise "No jekyll command provided."
      end

      requested_jekyll_command = requested_jekyll_command.downcase
      jekyll_config = get_config(requested_jekyll_command)

      case requested_jekyll_command.downcase
      when "build"
        Jekyll::Commands::Build.process(jekyll_config)
      when "serve"
        Jekyll::Commands::Serve.process(jekyll_config)
      end

      # If the default_config_file is assigned and the jekyll command supports '--config',
      # apply the default config by performing some positional argument magic.
      # if default_config_file_path #" ] && bundle exec jekyll "$2" --help | grep '\-\-config' > /dev/null; then
      #   exec("bundle exec jekyll $2 --config $default_config_file ${@:3}")
      # else
      #   exec("bundle exec jekyll ${@:2}")
      # end
    end

    def execute_unknown
      puts "Running '$*' (env: #{@jekyll_env})..."
      exec "$@"
    end

    def get_config(command)
      config_file_path = File.join(Dir.pwd, "_config.yml")

      unless File.file?(config_file_path)
        default_config_file_path = File.join(@jekyll_var_dir, "_config.default.yml")
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

Jekyll::PlantUml::Entrypoint.new.execute
