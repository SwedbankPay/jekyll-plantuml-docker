require "jekyll"
require "html-proofer"
require "html-proofer-unrendered-markdown"

module Jekyll::PlantUml
  class Verifier
    def initialize(jekyll_config)
      if jekyll_config.nil? || jekyll_config.empty?
        raise "Nil or empty Jekyll config"
      end

      @jekyll_config = jekyll_config
    end

    def verify
      unless @jekyll_config.has_key? "destination"
        raise "No 'destination' key found in the Jekyll config"
      end

      jekyll_destination_dir = @jekyll_config["destination"]

      unless Dir.exist?(jekyll_destination_dir)
        raise "#{@jekyll_destination_dir} does not exist"
      end

      html_glob = File.join(jekyll_destination_dir, "**/*.html")

      if Dir.glob(html_glob).empty?
        raise "#{jekyll_destination_dir} contains no .html files"
      end

      options = {
        :assume_extension => true,
        :check_html => true,
        :enforce_https => true,
        :only_4xx => true,
        :check_unrendered_link => true,
      }

      HTMLProofer.check_directory(jekyll_destination_dir, options).run
    end
  end
end
