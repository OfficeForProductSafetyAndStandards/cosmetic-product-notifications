require "application_system_test_case"

class RecordEmailCorrespondenceTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin
    @investigation = investigations(:one)
    @investigation.source = sources(:investigation_one)
    @correspondence = correspondences(:email)
    visit new_investigation_email_url(@investigation)
  end

  teardown do
    logout
  end

  test "first step should be context" do
    assert_text("Email details")
  end

  test "validates presence of date" do
    click_button "Continue"
    assert_text "date can't be blank"
  end

  test "validates date format" do
    fill_in "correspondence_email[day]", with: "333"
    click_on "Continue"
    assert_text "must specify a day, month and year"
  end

  test "second step should be content" do
    fill_in_context_form
    click_button "Continue"
    assert_text("Email content")
  end

  test "attaches the email file" do
    attachment_filename = "testImage.png"

    fill_in_context_form
    click_button "Continue"
    attach_file("correspondence_email[email_file][file]", Rails.root + "test/fixtures/files/#{attachment_filename}")
    fill_in_content_form
    click_button "Continue"

    assert_text(attachment_filename)
    click_button "Continue"

    assert_text("Email: #{attachment_filename}")
    assert_text("View email file")

    click_on "Attachments"
    assert_text("correspondence overview")
    assert_text("Original email as a file")
  end

  test "attaches the email attachment" do
    attachment_filename = "testImage2.png"

    fill_in_context_form
    click_button "Continue"
    attach_file("correspondence_email[email_attachment][file]", Rails.root + "test/fixtures/files/#{attachment_filename}")
    fill_in_content_form
    click_button "Continue"

    assert_text(attachment_filename)
    click_button "Continue"

    assert_text("Attached: #{attachment_filename}")
    assert_text("View email attachment")

    click_on "Attachments"
    assert_text("correspondence overview")
  end

  test "third step should be confirmation" do
    fill_in_context_form
    click_button "Continue"
    fill_in_content_form
    click_button "Continue"
    assert_text "Confirm email details"
    assert_text "Attachments"
  end

  test "confirmation edit details should go to first page in flow" do
    fill_in_context_form
    click_button "Continue"
    fill_in_content_form
    click_button "Continue"
    click_on "Edit details"
    assert_text "Email details"
    assert_no_text "attachment"
  end

  test "edit details should retain changed values" do
    fill_in_context_form
    click_button "Continue"
    fill_in_content_form
    click_button "Continue"
    click_on "Edit details"
    assert_equal(@correspondence.correspondent_name, find_field('correspondence_email[correspondent_name]').value)
    assert_not_equal('', find_field('correspondence_email[correspondent_name]').value)
  end

  test "confirmation continue should go to case page" do
    visit new_investigation_email_url(investigations(:no_products))
    fill_in_context_form
    click_button "Continue"
    fill_in_content_form
    click_button "Continue"
    click_button "Continue"
    assert_current_path(/cases\/\d+/)
  end

  test "requires details to be no longer than 1000 characters" do
    more_than_1000_characters = "a" * 1001
    exactly_1000_characters = "a" * 1000
    test_request = Correspondence.create(investigation: @investigation, correspondence_date: @correspondence.correspondence_date)
    test_request.details = more_than_1000_characters
    assert_not test_request.save
    test_request.details = exactly_1000_characters
    assert test_request.save
  end

  def fill_in_context_form
    choose("correspondence_email[email_direction]", visible: false, option: :inbound)
    fill_in "correspondence_email[correspondent_name]", with: @correspondence.correspondent_name
    fill_in "correspondence_email[email_address]", with: @correspondence.email_address
    fill_in "Day", with: @correspondence.correspondence_date.day
    fill_in "Month", with: @correspondence.correspondence_date.month
    fill_in "Year", with: @correspondence.correspondence_date.year
  end

  def fill_in_content_form
    fill_in "correspondence_email[overview]", with: "correspondence overview"
    fill_in "correspondence_email[email_subject]", with: "email subject"
    fill_in "correspondence_email[details]", with: "email body"
  end
end
