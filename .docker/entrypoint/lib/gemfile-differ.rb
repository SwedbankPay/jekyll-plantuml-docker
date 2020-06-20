# frozen_string_literal: true

require_relative 'padder'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::GemfileDiffer class performs diffing of Gemfiles.
    class GemfileDiffer
      def initialize(debug = false)
        @debug = debug
      end

      def diff(primary_gemfile_path, secondary_gemfile_path)
        raise "#{primary_gemfile_path} cannot be found." unless File.exist? primary_gemfile_path

        unless File.exist? secondary_gemfile_path
          puts "#{secondary_gemfile_path} not found." if @debug
          return []
        end

        puts "Sourcing gems from #{secondary_gemfile_path}..." if @debug

        primary_gemfile_lines = read_lines(primary_gemfile_path)
        secondary_gemfile_lines = read_lines(secondary_gemfile_path)

        padder = Padder.new(secondary_gemfile_lines.length.to_s.length)

        secondary_gemfile_lines.each_with_index do |line, index|
          padder.puts line, index + 1

          # Only care about lines starting with "gem"
          next unless line.start_with? 'gem'

          gem_part = get_gem_part(line)

          # If we already have the gem mentioned in this very Gemfile, skip it
          match_index = line_index_of_substring(primary_gemfile_lines, gem_part)

          if match_index >= 0
            matching_line_number = match_index + 1
            padder.puts "#{gem_part} found on line #{matching_line_number}. Skipping."
            next
          end

          padder.puts "Yielding #{line.strip}."

          yield line
        end
      end

      private

      def get_gem_part(line)
        gem_part = line

        # If the line contains a comma, get everything before the comma
        # (ignoring version and group for now)
        gem_part = line.split(',')[0] if line.include? ','

        gem_part.strip
      end

      def line_index_of_substring(lines, substring)
        lines.each_with_index do |line, index|
          return index if line.include? substring
        end

        -1
      end

      def read_lines(file_path)
        File.open(file_path, &:readlines)
      end
    end
  end
end
