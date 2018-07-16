ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
require "rails/test_help"

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def sign_in_as_admin
    user = users(:one)
    user.add_role(:user)
    user.add_role(:admin)
    sign_in user
  end

  def sign_in_as_user
    user = users(:two)
    user.add_role(:user)
    sign_in user
  end
end
