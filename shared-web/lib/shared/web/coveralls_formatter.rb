require 'coveralls'

# Custom Coveralls formatter to allow Coveralls to handle both PSD and Cosmetics in the same
# repo. Returns file paths that include the leading app name to avoid confusion between files
# with the same name in both apps.
# See https://github.com/lemurheavy/coveralls-ruby/blob/master/lib/coveralls/simplecov.rb
module Shared
  module Web
    class CoverallsFormatter < Coveralls::SimpleCov::Formatter
      def short_filename(filename)
        filename[1..-1]
      end
    end
  end
end
