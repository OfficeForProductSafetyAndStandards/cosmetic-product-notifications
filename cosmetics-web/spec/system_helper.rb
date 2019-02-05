require "capybara/rspec"
require "selenium-webdriver"

ENV["HTTP_HOST"] = "localhost"
ENV["HTTP_PORT"] = "3003"

Capybara.server_host = ENV["HTTP_HOST"]
Capybara.server_port = ENV["HTTP_PORT"]
Capybara.app_host = "http://#{ENV['HTTP_HOST']}:#{ENV['HTTP_PORT']}"
Capybara.default_host = "http://#{ENV['HTTP_HOST']}:#{ENV['HTTP_PORT']}"

Capybara.server = :puma, { Silent: true }

# Register headless Chrome as a Selenium driver (default RackTest driver does not support JavaScript)
Capybara.register_driver :chrome_headless do |app|
  options = ::Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--headless")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")
  options.add_argument("--window-size=1400,1400")

  client = ::Selenium::WebDriver::Remote::Http::Default.new
  client.read_timeout = 180

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options, http_client: client)
end

Capybara.javascript_driver = :chrome_headless

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :chrome_headless
  end
end
