return if Rails.env.production?

require 'coveralls'
require 'simplecov'

task :submit_coverage do
  ENV["COVERALLS_PARALLEL"] = "true"
  SimpleCov.merge_timeout(48 * 60 * 60) # Set time allowed between runs to 48 hours
  Coveralls.push!
end
