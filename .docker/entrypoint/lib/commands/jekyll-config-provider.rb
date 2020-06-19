require "jekyll"

module Jekyll::PlantUml
  class JekyllConfigProvider
    def initialize(jekyll_data_dir)
      @jekyll_data_dir = jekyll_data_dir
    end

    def get_config(jekyll_command)
      config_file_path = File.join(@jekyll_data_dir, "_config.yml")

      unless File.file?(config_file_path)
        default_config_file_path = File.join(__dir__, "..", "..", "_config.default.yml")
        default_config_file_path = File.expand_path(default_config_file_path)
        log(:info, "No _config.yml found. Using default: #{default_config_file_path}")
        config_file_path = default_config_file_path
      end

      jekyll_config = Jekyll.configuration({
        "config" => config_file_path,
        "incremental" => true,
        "base_url" => "",
        "source" => @jekyll_data_dir,
        "destination" => File.join(@jekyll_data_dir, "_site"),
      })

      begin
        ghm = Jekyll::GitHubMetadata
        ghm.site = Jekyll::Site.new(jekyll_config)
        gh_client = Jekyll::GitHubMetadata::Client.new
        pages = gh_client.pages(ghm.repository.nwo)

        log(:info, "Setting site.url to <#{pages.html_url}>.")

        jekyll_config.merge({
          "url" => pages.html_url,
        })
      rescue => exception
        log(:error, "Unable to retrieve GitHub metadata. URLs may be wrong in the resulting HTML. \n
Defining the JEKYLL_GITHUB_TOKEN environment variable may help. See the following issue for details: \n
https://github.com/github/pages-gem/issues/399#issuecomment-450799841 \n
#{exception}")
      end

      if jekyll_command == "serve"
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

    private

    def log(severity, message)
      (@logger ||= Jekyll.logger).public_send(severity, "jekyll-plantuml: #{message}")
    end
  end
end
