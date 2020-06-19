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

        puts "Reading #{primary_gemfile_path}..." if @debug
        original_file = File.readlines File.join(primary_gemfile_path)
        generated_file = original_file

        puts "Diffing #{secondary_gemfile_path}..." if @debug
        gemfile_differ = Jekyll::PlantUml::GemfileDiffer.new(@debug)
        gemfile_differ.diff(primary_gemfile_path, secondary_gemfile_path) do |line|
          generated_file << line
        end

        puts "Generating #{generated_gemfile_path}..." if @debug
        File.open(generated_gemfile_path, "w") { |file| file.puts(generated_file) }
      end
    end
  end
end
