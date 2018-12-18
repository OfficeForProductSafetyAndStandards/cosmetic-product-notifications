require 'coveralls'

# Custom Coveralls formatter to allow Coveralls to handle both MSPSDS and Cosmetics in the same
# repo. Returns file paths that include the leading app name to avoid confusion between files
# with the same name in both apps.
# See https://github.com/lemurheavy/coveralls-ruby/blob/master/lib/coveralls/simplecov.rb
module Shared
  module Web
    class CoverallsFormatter < Coveralls::SimpleCov::Formatter
      def get_source_files(result)
        # Gather the source files.
        source_files = []
        result.files.each do |file|
          properties = {}

          # Get Source
          properties[:source] = File.open(file.filename, "rb:utf-8").read

          # Return the absolute file path, minus the leading '/'. This will match the path in Github.
          properties[:name] = file.filename[1..-1]

          # Get the coverage
          properties[:coverage] = file.coverage.dup

          # Skip nocov lines
          file.lines.each_with_index do |line, i|
            properties[:coverage][i] = nil if line.skipped?
          end

          source_files << properties
        end
        source_files
      end

      def format(result)

        unless Coveralls.should_run?
          if Coveralls.noisy?
            display_result result
          end
          return
        end

        # Post to Coveralls.
        Coveralls::API.post_json "jobs",
                      :source_files => get_source_files(result),
                      :test_framework => result.command_name.downcase,
                      :run_at => result.created_at

        Coveralls::Output.puts output_message result

        true

      rescue Exception => e
        display_error e
      end
    end
  end
end
