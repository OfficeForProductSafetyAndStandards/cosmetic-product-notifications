ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
require "rails/test_help"
require "rspec/mocks/standalone"

class ActiveSupport::TestCase
  include ::RSpec::Mocks::ExampleMethods

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def sign_in_as_admin
    admin = {:sub => "admin", :email => "admin@example.com", :firstName => "First", :lastName => "Last"}
    stub_credentials(user: admin, is_admin: true)
  end

  def sign_in_as_user
    user = {:sub => "user", :email => "user@example.com", :firstName => "First", :lastName => "Last"}
    stub_credentials(user: user, is_admin: false)
  end

  private

  def stub_credentials(user:, is_admin: false)
    allow(Keycloak::Client).to receive(:user_signed_in?).and_return(true)
    allow(Keycloak::Client).to receive(:get_userinfo).and_return(user.to_json)
    allow(Keycloak::Client).to receive(:has_role?).with(:admin).and_return(is_admin)
  end
end
