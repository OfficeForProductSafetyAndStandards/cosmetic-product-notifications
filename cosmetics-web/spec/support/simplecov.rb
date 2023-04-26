require "simplecov"
require "simplecov-lcov"

SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov::Formatter::LcovFormatter.config.single_report_path = "coverage/lcov.info"
SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter
unless SimpleCov.running
  SimpleCov.start "rails"
end
