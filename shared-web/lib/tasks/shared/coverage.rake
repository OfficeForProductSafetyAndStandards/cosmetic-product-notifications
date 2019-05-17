require 'coveralls'

# Custom formatter to allow Coveralls to handle both Cosmetics and PSD in the same repo.
# Returns file paths that include the leading app name to avoid confusion between files
# with the same name in both apps.
# See https://github.com/lemurheavy/coveralls-ruby/blob/master/lib/coveralls/simplecov.rb
module Coveralls
  module SimpleCov
    class Formatter
      def short_filename(filename)
        filename[1..-1].gsub(/.*\/vendor\/shared-web\//, 'shared-web/')
      end
    end
  end
end

task :submit_coverage do
  ENV["COVERALLS_PARALLEL"] = "true"
  Coveralls.push!
end
