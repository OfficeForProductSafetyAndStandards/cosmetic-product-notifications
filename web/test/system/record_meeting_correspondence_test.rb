require "application_system_test_case"

class RecordMeetingCorrespondenceTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin
    @investigation = investigations(:one)
    @investigation.source = sources(:investigation_one)
    @activity = activities(:one)
    @activity.source = sources(:activity_one)
    visit new_investigation_meeting_url(@investigation)
  end

  teardown do
    logout
  end

  test "first step is context" do
    assert_text("Who was the meeting with?")
  end

  test "first step validates date" do
    fill_in("correspondence[day]", with: "333")
    click_on "Continue"
    assert_text("must be a valid date")
  end

  test "second step is content" do
    click_button "Continue"
    assert_text("Give an overview of the meeting")
  end

  test "attaches the transcript file" do
    click_button "Continue"
    attach_file("correspondence[transcript][file]", Rails.root + "test/fixtures/files/testImage.png")
    click_button "Continue"
    assert_text("testImage")
    click_button "Continue"
    assert_text("testImage")
  end

  test "attaches the related attachment" do
    click_button "Continue"
    attach_file("correspondence[related_attachment][file]", Rails.root + "test/fixtures/files/testImage2.png")
    click_button "Continue"
    assert_text("testImage2")
    click_button "Continue"
    assert_text("testImage2")
  end

  test "third step is confirmation" do
    click_button "Continue"
    click_button "Continue"
    assert_text "Confirm meeting details"
    assert_text "Attachments"
  end

  test "confirmation edit details links to first page in flow" do
    click_button "Continue"
    click_button "Continue"
    click_on "Edit details"
    assert_text "Who was the meeting with?"
    assert_no_text "attachment"
  end

  test "edit details retains changed values" do
    fill_in("correspondence[correspondent_name]", with: "Tom")
    click_button "Continue"
    click_button "Continue"
    click_on "Edit details"
    assert_equal('Tom', find_field('correspondence[correspondent_name]').value)
    assert_not_equal('', find_field('correspondence[correspondent_name]').value)
  end

  test "confirmation continue returns to case page" do
    visit new_investigation_meeting_url(investigations(:no_products))
    click_button "Continue"
    click_button "Continue"
    click_button "Continue"
    assert_text("There are no products attached to this case")
  end
end
