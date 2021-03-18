require "capybara/rspec"
require "capybara-screenshot/rspec"
require "capybara/mechanize"

Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app, respect_data_method: true, headers: { "HTTP_USER_AGENT" => "Capybara" })
end

Capybara.register_driver :mechanize do |_app|
  Capybara::Mechanize::Driver.new(proc {})
end
