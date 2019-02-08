require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    sign_in_as_user

    user = User.find_by(last_name: "User_one")
    admin = User.find_by(last_name: "Admin")
    organisations = Organisation.all

    user_groups = [
      { id: user[:id], groups: [organisations[0][:id]] },
      { id: admin[:id], groups: [organisations[1][:id]] }
    ].to_json

    allow(Keycloak::Internal).to receive(:get_user_groups).and_return(user_groups)
    User.all

    @user = User.find_by(last_name: "User_one")
    @admin = User.find_by(last_name: "Admin")
  end

  teardown do
    logout
  end

  test "display name includes user's organisation" do
    assert_equal "Test User_one (Organisation 1)", @user.display_name
    assert_equal "Test Admin (Office of Product Safety and Standards)", @admin.display_name
  end

  test "assignee short name is full name when user's organisation is same as that of current user" do
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
