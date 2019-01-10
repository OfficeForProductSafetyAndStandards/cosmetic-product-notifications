require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    sign_in_as_user_with_organisation

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
    assert_equal "Test Admin (Organisation 2)", @admin.display_name
  end

  test "assignee short name is full name when user's organisation is same as that of current user" do
    assert_equal "Test User_one", @user.assignee_short_name
  end

  test "assignee short name is organisation when user's organisation is different to that of current user" do
    assert_equal "Organisation 2", @admin.assignee_short_name
  end

  test "assignee select option keys include all user display names" do
    options = User.get_assignees_select_options

    assert_includes options.keys, @user.display_name
    assert_includes options.keys, @admin.display_name
  end

  test "assignee select option values include all user IDs" do
    options = User.get_assignees_select_options

    assert_includes options.values, @user.id
    assert_includes options.values, @admin.id
  end

  test "assignee select options exclude specified user" do
    options = User.get_assignees_select_options(except: @admin)

    assert_includes options.values, @user.id
    assert_not_includes options.values, @admin.id
  end

  test "assignee select options use full names when short names are enabled" do
    options = User.get_assignees_select_options(use_short_name: true)

    assert_includes options.keys, @user.full_name
    assert_includes options.keys, @admin.full_name
  end
end
