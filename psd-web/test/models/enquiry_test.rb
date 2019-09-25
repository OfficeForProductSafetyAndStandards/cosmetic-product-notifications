require "test_helper"

class EnquiryTest < ActiveSupport::TestCase
  include Pundit
    # Pundit requires this method to be able to call policies
  def pundit_user
    User.current
  end

  setup do
    mock_out_keycloak_and_notify
  end

  teardown do
    reset_keycloak_and_notify_mocks
  end

  test "enquiry with correct date" do
    investigation = load_case(:enquiry)
    assert_equal "2019-01-01", investigation.date_received.to_s
  end

  test "enquiry received date validated" do
    user = User.find_by(name: "Test User_one")
    investigation = load_case(:enquiry_with_no_date)
    investigation.update(assignee: user)
    assert_includes investigation.past_assignees, user
  end

  test "enquiry received date validated with date" do
    user = User.find_by(name: "Test User_one")
    investigation = load_case(:enquiry)
    investigation.update(assignee: user)
    assert_includes investigation.past_assignees, user
  end
end
