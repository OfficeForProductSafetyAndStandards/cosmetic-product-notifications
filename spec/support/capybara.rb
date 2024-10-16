require "capybara/rspec"
require "capybara-screenshot/rspec"

Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app, respect_data_method: true, headers: { "HTTP_USER_AGENT" => "Capybara" })
end
