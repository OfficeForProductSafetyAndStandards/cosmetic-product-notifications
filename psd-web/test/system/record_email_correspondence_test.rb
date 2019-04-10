require "application_system_test_case"
require_relative "../test_helpers/investigation_test_helper"

class RecordEmailCorrespondenceTest < ApplicationSystemTestCase
  include InvestigationTestHelper

  setup do
    mock_out_keycloak_and_notify
    @investigation = load_case(:one)
    @investigation.source = sources(:investigation_one)
    set_investigation_source! @investigation, User.current
    @correspondence = correspondences(:email)
    visit new_investigation_email_url(@investigation)
  end

  teardown do
    reset_keycloak_and_notify_mocks
  end

  test "first step should be context" do
    assert_text("Email details")
  end

  test "validates presence of date" do
    click_button "Continue"
    assert_text "Enter correspondence date"
  end

  test "validates date format" do
    fill_in "correspondence_email[correspondence_date][day]", with: "333"
    click_on "Continue"
    assert_text "must include a month and year"
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
    click_on "Activity"
    assert_text("Email: #{attachment_filename}")
    assert_text("View email file")

    click_on "Attachments"
    assert_text(@correspondence.overview)
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
    click_on "Activity"
    assert_text("Attached: #{attachment_filename}")
    assert_text("View email attachment")

    click_on "Attachments"
    assert_text(@correspondence.overview)
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
    visit new_investigation_email_url(load_case(:no_products))
    fill_in_context_form
    click_button "Continue"
    fill_in_content_form
    click_button "Continue"
    click_button "Continue"
    assert_current_path(/cases\/\d+/)
  end

  test "requires details to be no longer than 50000 characters" do
    more_than_50000_characters = "a" * 50001
    exactly_50000_characters = "a" * 50000
    test_request = Correspondence.create(
      investigation: @investigation,
      correspondence_date: @correspondence.correspondence_date
    )
    test_request.details = more_than_50000_characters
    assert_not test_request.save
    test_request.details = exactly_50000_characters
    assert test_request.save
  end

  test "conceals information from other organisations on emails with customer info" do
    fill_in_context_form
    choose :correspondence_email_has_consumer_info_true, visible: false
    click_button "Continue"
    fill_in_content_form
    click_button "Continue"
    click_button "Continue"

    other_org_user = User.find_by name: "Test Ts_user"
    sign_in_as other_org_user
    visit investigation_path(@investigation)

    click_on "Activity"
    within id: "activity" do
      assert_equal("Email added", first('h3').text)
      assert_equal("RESTRICTED ACCESS", first(".hmcts-badge").text)
    end
  end

  test "does not conceal consumer information from assignee" do
    other_org_user = User.find_by name: "Test Ts_user"
    set_investigation_assignee! @investigation, other_org_user
    fill_in_context_form
    choose :correspondence_email_has_consumer_info_true, visible: false
    click_button "Continue"
    fill_in_content_form
    click_button "Continue"
    click_button "Continue"

    sign_in_as other_org_user
    visit investigation_path(@investigation)

    click_on "Activity"
    within id: "activity" do
      assert_equal(@correspondence.overview, first('h3').text)
    end
  end

  test "does not conceal consumer information from assignee's team" do
    other_org_user = User.find_by name: "Test Ts_user"
    sign_in_as other_org_user
    assignee = User.find_by name: "Test User_one"
    same_team_user = User.find_by name: "Test User_four"

    set_investigation_assignee! @investigation, assignee
    fill_in_context_form
    choose :correspondence_email_has_consumer_info_true, visible: false
    click_button "Continue"
    fill_in_content_form
    click_button "Continue"
    click_button "Continue"

    sign_in_as same_team_user
    visit investigation_path(@investigation)

    click_on "Activity"
    within id: "activity" do
      assert_equal(@correspondence.overview, first('h3').text)
    end
  end

  test "does not conceal information from same organisation on emails with customer info" do
    fill_in_context_form
    choose :correspondence_email_has_consumer_info_true, visible: false
    click_button "Continue"
    fill_in_content_form
    click_button "Continue"
    click_button "Continue"

    same_org_user = User.find_by name: "Test User_three"
    sign_in_as same_org_user
    visit investigation_path(@investigation)

    click_on "Activity"
    within id: "activity" do
      assert_equal(@correspondence.overview, first('h3').text)
    end
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
    fill_in "correspondence_email[overview]", with: @correspondence.overview
    fill_in "correspondence_email[email_subject]", with: @correspondence.email_subject
    fill_in "correspondence_email[details]", with: @correspondence.details
  end
end
