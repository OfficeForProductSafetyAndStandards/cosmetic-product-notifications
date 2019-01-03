require "application_system_test_case"

class InvestigationAssigneeTest < ApplicationSystemTestCase
  setup do
    sign_in_as_user
    visit assign_investigation_path(investigations(:one))
  end

  teardown do
    logout
  end

  test "should show selection without radio buttons if the user hasn't been re-assigned" do
    assert_text "Name / Email address"
  end

  test "should allow to select assignee" do
    fill_in "assignee-picker", with: "("
    all("li", visible: false, text: "Admin").first.click
    click_on "Assign"
    assert_text("Assigned to\nTest Admin Change")
  end

  test "should allow to select a different assignee, the current one should not appear in the list" do
    fill_in "assignee-picker", with: "("
    all("li", visible: false, text: "Admin").first.click
    click_on "Assign"
    visit assign_investigation_path(investigations(:one))

    fill_in "assignee-picker", with: "("
    all("li", visible: false, text: "(").first.click
    click_on "Assign"
    assert_text("Assigned to\nTest User Change")
  end

  test "should require an actual assignee" do
    fill_in "assignee-picker", with: "aa@aa.aa"
    click_on "Assign"
    assert_text("Assignee should exist")
  end
end
