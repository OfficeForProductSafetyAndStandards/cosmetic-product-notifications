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

  # Import all relevant models into Elasticsearch
  def self.import_into_elasticsearch
    unless @models_imported
      ActiveRecord::Base.descendants.each do |model|
        if model.respond_to?(:__elasticsearch__)
          model.import force: true, refresh: true
        end
      end
      @models_imported = true
    end
  end

  def setup
    self.class.import_into_elasticsearch
  end

  # Add more helper methods to be used by all tests here...
  def sign_in_as_admin
    admin = admin_user
    stub_user_credentials(user: admin, is_admin: true)
    stub_user_data(users: [admin, test_user])
    stub_client_config
  end

  def sign_in_as_user
    user = test_user
    stub_user_credentials(user: user, is_admin: false)
    stub_user_data(users: [admin_user, user])
    stub_client_config
  end

  def logout
    allow(Keycloak::Client).to receive(:user_signed_in?).and_call_original
    allow(Keycloak::Client).to receive(:get_userinfo).and_call_original
    allow(Keycloak::Client).to receive(:has_role?).and_call_original
    allow(Keycloak::Client).to receive(:auth_server_url).and_call_original

    reset_user_data
  end

private

  def admin_user
    { id: SecureRandom.uuid, email: "admin@example.com", first_name: "Test", last_name: "Admin" }
  end

  def test_user
    { id: SecureRandom.uuid, email: "user@example.com", first_name: "Test", last_name: "User" }
  end

  def stub_user_credentials(user:, is_admin: false)
    allow(Keycloak::Client).to receive(:user_signed_in?).and_return(true)
    allow(Keycloak::Client).to receive(:get_userinfo).and_return(format_user_for_get_userinfo(user))
    allow(Keycloak::Client).to receive(:has_role?).with(:admin).and_return(is_admin)
  end

  def format_user_for_get_userinfo(user)
    { sub: user[:id], email: user[:email], given_name: user[:first_name], family_name: user[:last_name] }.to_json
  end

  def stub_client_config
    allow(Keycloak::Client).to receive(:auth_server_url).and_return("localhost")
  end

  def stub_user_data(users:)
    allow(Keycloak::Internal).to receive(:get_users).and_return(format_user_for_get_users(users))
    User.all
  end

  def format_user_for_get_users(users)
    users.map { |user| { id: user[:id], email: user[:email], firstName: user[:first_name], lastName: user[:last_name] } }.to_json
  end

  def reset_user_data
    allow(Keycloak::Internal).to receive(:get_users).and_call_original
    Rails.cache.delete(:keycloak_users)
  end
end
