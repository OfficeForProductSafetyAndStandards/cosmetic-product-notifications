require "application_system_test_case"
require_relative "../test_helpers/corrective_action_test_helper"

class CorrectiveActionsTest < ApplicationSystemTestCase
  include CorrectiveActionTestHelper
  setup do
    mock_out_keycloak_and_notify

    @investigation = load_case(:one)
    @corrective_action = corrective_actions(:one)

    visit new_investigation_corrective_action_path(@investigation)
    assert_selector "h1", text: "Record corrective action"
  end

  teardown do
    reset_keycloak_and_notify_mocks
  end

  test "can record corrective action for a case" do
    fill_in_corrective_action_details @corrective_action
    choose "corrective_action_related_file_yes", visible: false
    attach_file "attachment-file-input", file_fixture("new_risk_assessment.txt")
    click_on "Continue"

    assert_text "Confirm corrective action details"
    click_on "Continue"

    assert_current_path(/cases\/\d+/)
    click_on "Activity"
    assert_text @corrective_action.summary
    assert_text "Corrective action recorded"
  end

  test "can go back to the edit page from the confirmation page and not lose data" do
    fill_in_corrective_action_details @corrective_action
    choose "corrective_action_related_file_yes", visible: false
    attach_file "attachment-file-input", file_fixture("new_risk_assessment.txt")
    click_on "Continue"

    # Assert all of the data is still here
    assert_text @corrective_action.summary
    assert_text @corrective_action.legislation
    assert_text @corrective_action.details
    assert_text "15/11/2018"
    click_on "Edit details"

    # Assert we're back on the details page and haven't lost data
    assert_text "Record corrective action"
    assert_field with: @corrective_action.summary
    assert_field with: @corrective_action.date_decided.day
    assert_field with: @corrective_action.date_decided.month
    assert_field with: @corrective_action.date_decided.year
    assert_field with: @corrective_action.legislation
    assert_field with: @corrective_action.details
  end

  test "session data doesn't persist between reloads" do
    fill_in_corrective_action_details @corrective_action
    visit new_investigation_corrective_action_path(@investigation)

    assert_no_field with: @corrective_action.legislation
  end

  test "session data is cleared after completion" do
    fill_in_corrective_action_details @corrective_action
    click_on "Continue"
    click_on "Continue"

    visit new_investigation_corrective_action_path(@investigation)

    assert_no_field with: @corrective_action.legislation
  end

  test "cannot create a corrective action without specifying the date decided" do
    click_button "Continue"

    assert_text "Enter the date the corrective action was decided"
  end

  test "invalid date shows an error" do
    fill_in "Day", with: "7"
    fill_in "Month", with: "13"
    fill_in "Year", with: "1984"
    click_on "Continue"

    assert_text "Enter a real date when the corrective action was decided"
  end

  test "date with missing component shows an error" do
    fill_in "Day", with: "7"
    fill_in "Year", with: "1984"
    click_on "Continue"

    assert_text "Enter the date the corrective action was decided and include a day, month and year"
  end

  test "can add an attachment when recording a corrective action" do
    attachment_filename = "new_risk_assessment.txt"
    attachment_description = "Test attachment description"

    fill_in_corrective_action_details @corrective_action
    add_corrective_action_attachment filename: attachment_filename, description: attachment_description
    click_on "Continue"

    assert_text "Confirm corrective action details"
    assert_text attachment_filename
    assert_text attachment_description
    click_on "Continue"

    assert_current_path(/cases\/\d+/)
    click_on "Activity"
    assert_text "Attached: #{attachment_filename}"
    assert_text "View attachment"
  end

  test "corrective action attachment is added to the case attachments" do
    attachment_filename = "new_risk_assessment.txt"
    attachment_description = "Test attachment description"

    fill_in_corrective_action_details @corrective_action
    add_corrective_action_attachment filename: attachment_filename, description: attachment_description
    click_on "Continue"
    click_on "Continue"

    assert_current_path(/cases\/\d+/)
    click_on "Attachments"

    assert_text @corrective_action.summary
    assert_text attachment_description
  end

  test "attachment description field is not visible when no file is selected" do
    assert_no_text "Attachment description"
  end

  test "attachment description field is visible when a file is selected" do
    choose "corrective_action_related_file_yes", visible: false
    attach_file "corrective_action[file][file]", file_fixture("new_risk_assessment.txt")

    assert_text "Attachment description"
  end
end
