require "test_helper"

# Values from .env-template
ENV["KEYCLOAK_AUTH_URL"] = "http://keycloak:8080/auth"
ENV["KEYCLOAK_CLIENT_ID"] = "mspsds-app"
ENV["KEYCLOAK_CLIENT_SECRET"] = "932677f2-55c0-45c5-901a-f4beddb85e17"
ENV["HTTP_HOST"] = "localhost"
ENV["HTTP_PORT"] = "3001"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  Capybara.server_host = ENV["HTTP_HOST"]
  Capybara.server_port = ENV["HTTP_PORT"]
  Capybara.app_host = "http://#{ENV['HTTP_HOST']}:#{ENV['HTTP_PORT']}"
  Capybara.default_host = "http://#{ENV['HTTP_HOST']}:#{ENV['HTTP_PORT']}"
  driven_by :selenium, using: :chrome, screen_size: [1400, 1400], options: { args: ["headless", "disable-gpu", "no-sandbox", "disable-dev-shm-usage"] }
end
