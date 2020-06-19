require_relative "gemfile-generator"

module Jekyll
  module PlantUml
    class GemfileGeneratorExec
      def generate
        debug = ENV.fetch("DEBUG", false)
        jekyll_data_dir = ENV.fetch("JEKYLL_DATA_DIR", Dir.pwd)
        jekyll_var_dir = ENV.fetch("JEKYLL_VAR_DIR", Dir.pwd)
        primary_gemfile_path = File.join(jekyll_var_dir, "entrypoint", "Gemfile")
        secondary_gemfile_path = File.join(jekyll_data_dir, "Gemfile")
        generated_gemfile_path = File.join(jekyll_var_dir, "entrypoint", "Gemfile_generated")

        gemfile_generator = Jekyll::PlantUml::GemfileGenerator.new(debug)
        gemfile_generator.generate(primary_gemfile_path, secondary_gemfile_path, generated_gemfile_path)
      end
    end
  end
end

Jekyll::PlantUml::GemfileGeneratorExec.new.generate()
