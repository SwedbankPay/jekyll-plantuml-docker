require_relative "gemfile-differ"

module Jekyll
  module PlantUml
    class GemfileGenerator
      def initialize(debug = false)
        @debug = debug
      end

      def generate(primary_gemfile_path, secondary_gemfile_path, generated_gemfile_path)
        unless File.exists? primary_gemfile_path
          raise "#{primary_gemfile_path} cannot be found."
        end

        unless File.exists? secondary_gemfile_path
          raise "#{secondary_gemfile_path} cannot be found."
        end

        original_file = File.readlines File.join(primary_gemfile_path)
        generated_file = original_file

        gemfile_differ = Jekyll::PlantUml::GemfileDiffer.new(@debug)
        gemfile_differ.diff(primary_gemfile_path, secondary_gemfile_path) do |line|
          generated_file << line
        end
        File.open(generated_gemfile_path, "w") { |file| file.puts(generated_file) }
      end
    end
  end
end
