module Jekyll
  module PlantUml
    class GemfileMerger
      def initialize(primary_gemfile_path, secondary_gemfile_path)
        @debug = ENV.fetch("DEBUG", false)

        unless File.exists? primary_gemfile_path
          raise "#{primary_gemfile_path} cannot be found."
        end

        @primary_gemfile_path = primary_gemfile_path
        @secondary_gemfile_path = secondary_gemfile_path
      end

      def merge
        unless File.exists? @secondary_gemfile_path
          puts "#{@secondary_gemfile_path} not found." if @debug
          return
        end

        puts "Sourcing gems from #{@secondary_gemfile_path}..." if @debug

        primary_gemfile_lines = read_lines(@primary_gemfile_path)
        secondary_gemfile_lines = read_lines(@secondary_gemfile_path)

        pad_length = secondary_gemfile_lines.length.to_s.length
        padding = "%#{pad_length}s" % "" + " "

        secondary_gemfile_lines.each_with_index do |line, index|
          line_number = index + 1
          line_number = "%#{pad_length}d" % line_number

          puts "#{line_number}: #{line}" if @debug

          # Only care about lines starting with "gem"
          next unless line.start_with? "gem"

          gem_part = get_gem_part(line)

          # If we already have the gem mentioned in this very Gemfile, skip it
          match_index = lines_index_of_substring(primary_gemfile_lines, gem_part)

          if match_index >= 0
            matching_line_number = match_index + 1
            puts "#{padding} #{gem_part} found on line #{matching_line_number}. Skipping."
            next
          end

          puts "#{padding} Loading #{line.strip}." if @debug
          instance_eval line
        end
      end

      private

      def get_gem_part(line)
        gem_part = line

        # If the line contains a comma, get everything before the comma
        # (ignoring version and group for now)
        gem_part = line.split(",")[0] if line.include? ","

        gem_part.strip
      end

      def lines_index_of_substring(lines, substring)
        lines.each_with_index do |line, index|
          return index if line.include? substring
        end

        -1
      end

      def read_lines(file_path)
        File.open(file_path) do |file|
          file.readlines
        end
      end
    end
  end
end
