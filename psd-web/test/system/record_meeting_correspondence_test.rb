require "application_system_test_case"

class RecordMeetingCorrespondenceTest < ApplicationSystemTestCase
  setup do
    mock_out_keycloak_and_notify
    @investigation = load_case(:one)
    @investigation.source = sources(:investigation_one)
    @correspondence = correspondences(:meeting)
    visit new_investigation_meeting_url(@investigation)
  end

  teardown do
    reset_keycloak_and_notify_mocks
  end

  test "first step is context" do
    assert_text("Who was the meeting with?")
  end

  test "first step validates date" do
    fill_in("correspondence_meeting[correspondence_date][day]", with: "333")
    click_on "Continue"
    assert_text("Correspondence date must specify a day, month and year")
  end

  test "second step is content" do
    fill_in_context_form
    click_button "Continue"
    assert_text("Give an overview of the meeting")
  end

  test "attaches the transcript file" do
    fill_in_context_form
    click_button "Continue"
    attach_file("correspondence_meeting[transcript][file]", file_fixture("testImage.png"))
    click_button "Continue"
    assert_text("testImage")
    click_button "Continue"
    click_on "Activity"
    assert_text("testImage")
  end

  test "attaches the related attachment" do
    fill_in_context_form
    click_button "Continue"
    fill_in_content_form
    attach_file("correspondence_meeting[related_attachment][file]", file_fixture("testImage2.png"))
    click_button "Continue"
    assert_text("testImage2")
    click_button "Continue"
    click_on "Activity"
    assert_text("testImage2")
  end

  test "must have either transcript or summary and notes" do
    fill_in_context_form
    click_button "Continue"
    click_button "Continue"
    assert_text "Please provide either a transcript or complete the summary and notes fields"
  end

  test "third step is confirmation" do
    fill_in_context_form
    click_button "Continue"
    fill_in_content_form
    click_button "Continue"
    assert_text "Confirm meeting details"
    assert_text "Attachments"
  end

  test "confirmation edit details links to first page in flow" do
    fill_in_context_form
    click_button "Continue"
    fill_in_content_form
    click_button "Continue"
    click_on "Edit details"
    assert_text "Who was the meeting with?"
    assert_no_text "attachment"
  end

  test "edit details retains changed values" do
    fill_in_context_form
    click_button "Continue"
    fill_in_content_form
    click_button "Continue"
    click_on "Edit details"
    assert_equal(@correspondence.correspondent_name, find_field('correspondence_meeting[correspondent_name]').value)
  end

  test "confirmation continue returns to case page" do
    fill_in_context_form
    click_button "Continue"
    fill_in_content_form
    click_button "Continue"
    click_button "Continue"
    assert_current_path(/cases\/\d+/)
  end

  def fill_in_context_form
    fill_in "correspondence_meeting[correspondent_name]", with: @correspondence.correspondent_name
    fill_in "Day", with: @correspondence.correspondence_date.day
    fill_in "Month", with: @correspondence.correspondence_date.month
    fill_in "Year", with: @correspondence.correspondence_date.year
  end

  def fill_in_content_form
    fill_in "correspondence_meeting[overview]", with: @correspondence.overview
    fill_in "correspondence_meeting[details]", with: @correspondence.details
  end
end
