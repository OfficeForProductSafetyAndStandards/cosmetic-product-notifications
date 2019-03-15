require "application_system_test_case"

class InvestigationAssigneeTest < ApplicationSystemTestCase
  setup do
    sign_in_as_user
    @user = User.find_by(last_name: "User_one")
    @team = @user.teams.first
    visit assign_investigation_path(investigations(:one))
  end

  teardown do
    logout
  end

  test "should show current user as a radio, and to assign user to case" do
    assert_text @user.display_name
    choose @user.display_name, visible: false
    click_on "Continue"
    click_on "Confirm change"
    assert_text "Assigned to\n#{@user.display_name}"
    click_on "Activity"
    assert_text "Assigned to #{@user.display_name}"
  end

  test "should show current users team as a radio, and to assign team to case" do
    assert_text @team.name
    choose @team.name, visible: false
    click_on "Continue"
    click_on "Confirm change"
    assert_text "Assigned to\n#{@team.name}"
    click_on "Activity"
    assert_text "Assigned to #{@team.name}"
  end

  test "should add comment current to assignment activity" do
    assert_text @team.name
    choose @team.name, visible: false
    click_on "Continue"
    fill_in "Message to new assignee (optional)", with: "Test assignment comment"
    click_on "Confirm change"
    assert_text "Assigned to\n#{@team.name}"
    click_on "Activity"
    assert_text "Assigned to #{@team.name}"
    assert_text "Test assignment comment"
  end
end
