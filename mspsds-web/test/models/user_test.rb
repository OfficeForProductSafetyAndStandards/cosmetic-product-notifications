require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    mock_out_keycloak_and_notify
    @user = User.find_by(last_name: "User_one")
    @admin = User.find_by(last_name: "Admin")
    set_user_as_non_opss(@user)
    set_user_as_opss(@admin)
  end

  teardown do
    reset_keycloak_and_notify_mocks
  end

  test "display name includes user's organisation for non-org-member viewers" do
    sign_in_as @admin
    assert_equal "Test User_one (Organisation 1)", @user.display_name

    sign_in_as @user
    assert_equal "Test Admin (Office of Product Safety and Standards)", @admin.display_name
  end

  test "assignee short name is full name when user's organisation is same as that of current user" do
    sign_in_as @user
    assert_equal "Test User_one", @user.assignee_short_name
  end

  test "assignee short name is organisation when user's organisation is different to that of current user" do
    assert_equal "Office of Product Safety and Standards", @admin.assignee_short_name
  end

  test "get_assignees includes all users by default" do
    options = User.get_assignees

    assert_includes options, @user
    assert_includes options, @admin
  end

  test "get_assignees exclude specified user" do
    options = User.get_assignees(except: @admin)

    assert_includes options, @user
    assert_not_includes options, @admin
  end
end
