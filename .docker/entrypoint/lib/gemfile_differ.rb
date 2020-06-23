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
        raise "#{primary_gemfile_path} cannot be found." unless path_valid(primary_gemfile_path)
        return [] unless path_valid(secondary_gemfile_path)

        puts "\n\n----- Sourcing gems from #{secondary_gemfile_path} -----" if @debug

        primary_gemfile_lines = file_read_lines(primary_gemfile_path)
        secondary_gemfile_lines = file_read_lines(secondary_gemfile_path)

        puts secondary_gemfile_lines if @debug

        @padder = Padder.new(secondary_gemfile_lines.length.to_s.length, @debug)

        do_read_lines(primary_gemfile_lines, secondary_gemfile_lines) do |line|
          yield line
        end
      end

      private

      def path_valid(path)
        return true if File.exist? path

        puts "#{path} not found." if @debug

        false
      end

      def do_read_lines(primary_gemfile_lines, secondary_gemfile_lines)
        secondary_gemfile_lines.each_with_index do |line, index|
          @padder.write line, index + 1

          # Only care about lines starting with "gem"
          next unless line.start_with? 'gem'

          gem_part = get_gem_part(line)

          # If we already have the gem mentioned in this very Gemfile, skip it
          match_index = line_index_of_substring(primary_gemfile_lines, gem_part)
          next if match?(match_index, gem_part)

          @padder.write "Yielding #{line.strip}."

          yield line
        end
      end

      def match?(match_index, gem_part)
        if match_index >= 0
          matching_line_number = match_index + 1
          @padder.write "#{gem_part} found on line #{matching_line_number}. Skipping."
          return true
        end

        false
      end

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

      def file_read_lines(file_path)
        File.open(file_path, &:readlines)
      end
    end
  end
end
