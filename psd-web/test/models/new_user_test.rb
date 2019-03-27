require 'test_helper'

class NewUserTest < ActiveSupport::TestCase
  test "new user email address is validated" do
    invalid_new_user = NewUser.new email_address: "malformed_email"
    valid_new_user = NewUser.new email_address: "valid@email"

    assert_not invalid_new_user.valid?
    assert valid_new_user.valid?
  end
end
