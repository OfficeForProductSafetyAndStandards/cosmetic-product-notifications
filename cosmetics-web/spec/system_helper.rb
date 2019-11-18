require "capybara/rspec"
require "selenium-webdriver"

ENV["HTTP_HOST"] = "localhost"
ENV["HTTP_PORT"] = "3003"

ENV["SUBMIT_HOST"] = "localhost"
ENV["SEARCH_HOST"] = "localhost"

if ENV["CHROMEDRIVER_PATH"]
  Selenium::WebDriver::Chrome::Service.driver_path = ENV.fetch("CHROMEDRIVER_PATH")
end

Capybara.server_host = ENV["HTTP_HOST"]
Capybara.server_port = ENV["HTTP_PORT"]
Capybara.app_host = "http://#{ENV['HTTP_HOST']}:#{ENV['HTTP_PORT']}"
Capybara.default_host = "http://#{ENV['HTTP_HOST']}:#{ENV['HTTP_PORT']}"
Rails.application.routes.default_url_options = { host: ENV["HTTP_HOST"], port: ENV["HTTP_PORT"] }

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

Capybara.ignore_hidden_elements = false

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :chrome_headless
    ActiveJob::Base.queue_adapter = :inline
  end
end

# This module and method allows an individual test to temporarily turn
# on error page rendering (rather than raising an exception) in order to
# allow assertions based upon the rendered error page.
#
# Due to Rails config caching, this has to alter `env_config` directly
# rather than setting Rails.application.config.action_dispatch.show_exception
#
# See https://github.com/rspec/rspec-rails/issues/2024
module WithErrorPageRendering
  RSpec.configure do |config|
    config.include self, type: :system
  end

  def with_error_page_rendering
    env_config = Rails.application.env_config
    original_show_exceptions = env_config["action_dispatch.show_exceptions"]
    original_show_detailed_exceptions = env_config["action_dispatch.show_detailed_exceptions"]
    env_config["action_dispatch.show_exceptions"] = true
    env_config["action_dispatch.show_detailed_exceptions"] = false
    yield
  ensure
    env_config["action_dispatch.show_exceptions"] = original_show_exceptions
    env_config["action_dispatch.show_detailed_exceptions"] = original_show_detailed_exceptions
  end
end


def fill_autocomplete(locator, with:)
  fill_in locator, with: "#{with}\n"
end

def stub_notify_mailer
  result = double
  allow(result).to receive(:deliver_later)
  allow(NotifyMailer).to receive(:send_contact_person_verification_email) { result }
  allow(NotifyMailer).to receive(:send_responsible_person_invite_email) { result }
end
