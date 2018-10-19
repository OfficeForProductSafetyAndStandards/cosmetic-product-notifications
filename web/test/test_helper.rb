ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
require "rails/test_help"
require "rspec/mocks/standalone"

require 'simplecov'
require 'simplecov-console'
require 'coveralls'
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::Console,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

class ActiveSupport::TestCase
  include ::RSpec::Mocks::ExampleMethods

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  # Add more helper methods to be used by all tests here...

  def sign_in_as_admin
    user = build_admin_user :keycloak
    stub_user_credentials(user: user, is_admin: true)
    stub_client_config
    stub_user_data
  end

  def sign_in_as_user
    user = build_test_user :keycloak
    stub_user_credentials(user: user, is_admin: false)
    stub_client_config
    stub_user_data
  end

  def logout
    allow(Keycloak::Client).to receive(:user_signed_in?).and_call_original
    allow(Keycloak::Client).to receive(:get_userinfo).and_call_original
    allow(Keycloak::Client).to receive(:has_role?).and_call_original
    allow(Keycloak::Client).to receive(:auth_server_url).and_call_original
  end

private

  def build_admin_user source
    id = SecureRandom.uuid
    email = "admin@example.com"
    first_name = "admin_first"
    last_name = "admin_last"
    if source == :keycloak
      { sub: id, email: email, given_name: first_name, family_name: last_name }
    elsif source == :rails
      { id: id, email: email, first_name: first_name, last_name: last_name }
    end
  end

  def build_test_user source
    id = SecureRandom.uuid
    email = "user@example.com"
    first_name = "user_first"
    last_name = "user_last"
    if source == :keycloak
      { sub: id, email: email, given_name: first_name, family_name: last_name }
    elsif source == :rails
      { id: id, email: email, first_name: first_name, last_name: last_name }
    end
  end

  def stub_user_credentials(user:, is_admin: false)
    allow(Keycloak::Client).to receive(:user_signed_in?).and_return(true)
    allow(Keycloak::Client).to receive(:get_userinfo).and_return(user.to_json)
    allow(Keycloak::Client).to receive(:has_role?).with(:admin).and_return(is_admin)
  end

  def stub_client_config
    allow(Keycloak::Client).to receive(:auth_server_url).and_return("localhost")
  end

  def stub_user_data
    test_user = build_test_user :rails
    admin_user = build_admin_user :rails
    users_json = JSON.generate [test_user, admin_user]
    allow(Keycloak::Internal).to receive(:get_users).and_return(users_json)
  end
end
