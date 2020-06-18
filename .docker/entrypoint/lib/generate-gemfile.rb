require_relative "gemfile-differ"

module Jekyll
  module PlantUml
    class GenereateGemfile
      def initialize
        @debug = ENV.fetch("DEBUG", false)
        @jekyll_data_dir = ENV.fetch("JEKYLL_DATA_DIR", Dir.pwd)
        @jekyll_var_dir = ENV.fetch("JEKYLL_VAR_DIR", Dir.pwd)
      end

      def generate
        primary_gemfile_path = File.join(@jekyll_var_dir, "entrypoint","Gemfile")
        secondary_gemfile_path = File.join(@jekyll_data_dir, "Gemfile")
        generated_file_path = File.join(@jekyll_var_dir, "entrypoint", "Gemfile_generated")
        original_file = File.readlines File.join(primary_gemfile_path)
        generated_file = original_file

        gemfile_differ = Jekyll::PlantUml::GemfileDiffer.new(@debug)
        gemfile_differ.diff(primary_gemfile_path, secondary_gemfile_path) do |line|
           generated_file << line
        end
        File.open(generated_file_path, 'w') { |file| file.puts(generated_file) }
      end
    end
  end
end

Jekyll::PlantUml::GenereateGemfile.new.generate

