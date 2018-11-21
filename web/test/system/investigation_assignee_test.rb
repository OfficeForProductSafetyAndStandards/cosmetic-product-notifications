require "application_system_test_case"

class InvestigationIAssigneeTest < ApplicationSystemTestCase
  setup do
    sign_in_as_user
    visit assign_investigation_path(investigations(:one))
  end

  teardown do
    logout
  end

  test "should assign case to nobody when created with an activity" do
    visit new_report_path
    click_on "Continue"
    click_on "Continue"
    click_on "View the case you've just created"
    assert_text("Unassigned")
  end

  test "should show selection without radio buttons if the user hasn't been re-assigned" do
    assert_text "Name / Email address"
  end

  test "should allow to select assignee" do
    fill_in "assignee-picker", with: "("
    all("li", visible: false, text: "(").first.click
    click_on "Assign"
    assert_text("Assigned to\nTest Admin Change")
  end

  test "should allow to select a different assignee, the current one should not appear in the list" do
    fill_in "assignee-picker", with: "("
    all("li", visible: false, text: "(").first.click
    click_on "Assign"
    visit assign_investigation_path(investigations(:one))

    fill_in "assignee-picker", with: "("
    all("li", visible: false, text: "(").first.click
    click_on "Assign"
    assert_text("Assigned to\nTest User Change")
  end
end
