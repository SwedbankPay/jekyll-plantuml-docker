# frozen_string_literal: true

require_relative 'gemfile_generator'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::GemfileGeneratorExec executes the GemfileGenerator
    # by bootstrapping the environment.
    class GemfileGeneratorExec
      def generate
        debug = ENV.fetch('DEBUG', false)
        jekyll_data_dir = ENV.fetch('JEKYLL_DATA_DIR', Dir.pwd)
        jekyll_var_dir = ENV.fetch('JEKYLL_VAR_DIR', Dir.pwd)
        default_gemfile_path = File.join(jekyll_var_dir, 'entrypoint', 'Gemfile')
        user_gemfile_path = File.join(jekyll_data_dir, 'Gemfile')
        generated_gemfile_path = File.join(jekyll_var_dir, 'entrypoint', 'Gemfile.generated')

        gemfile_generator = Jekyll::PlantUml::GemfileGenerator.new(debug)
        gemfile_generator.generate(default_gemfile_path, user_gemfile_path, generated_gemfile_path)
      end
    end
  end
end

Jekyll::PlantUml::GemfileGeneratorExec.new.generate
