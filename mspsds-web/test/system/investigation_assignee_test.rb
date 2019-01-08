require "application_system_test_case"

class InvestigationAssigneeTest < ApplicationSystemTestCase
  setup do
    sign_in_as_user_with_organisation
    visit assign_investigation_path(investigations(:one))
  end

  teardown do
    logout
  end

  test "should show selection without radio buttons if the user hasn't been re-assigned" do
    assert_text "Name / Organisation"
    assert_no_css "input[type='radio']", visible: false
  end

  test "should show user organisations in the assignee list" do
    fill_in "assignee-picker", with: "Test"
    assert_text "Test User (Organisation 1)"
  end

  test "should allow to select assignee" do
    fill_in "assignee-picker", with: "Test"
    all("li", visible: false, text: "Admin").first.click
    click_on "Assign"

    assert_text "Assigned to\nTest Admin Change"
  end

  test "should allow to select a different assignee, the current one should not appear in the list" do
    fill_in "assignee-picker", with: "Test"
    all("li", visible: false, text: "Admin").first.click
    click_on "Assign"

    visit assign_investigation_path(investigations(:one))
    fill_in "assignee-picker", with: "Test"
    assert_no_css(".autocomplete__option", text: "Test Admin")

    all("li", visible: false, text: "User").first.click
    click_on "Assign"
    assert_text "Assigned to\nTest User\nOrganisation 1\nChange"
  end

  test "should show recent assignee as an option when previous assignees have been selected" do
    fill_in "assignee-picker", with: "Test"
    all("li", visible: false, text: "Admin").first.click
    click_on "Assign"

    visit assign_investigation_path(investigations(:one))
    fill_in "assignee-picker", with: "Test"
    all("li", visible: false, text: "User").first.click
    click_on "Assign"

    visit assign_investigation_path(investigations(:one))
    assert_css "input[type='radio']", visible: false
    assert_text "Test Admin"
    assert_text "Other"
  end

  test "should require an actual assignee" do
    fill_in "assignee-picker", with: "aa@aa.aa"
    click_on "Assign"
    assert_text("Assignee should exist")
  end
end
