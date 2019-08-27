require "application_system_test_case"

class CreateEnquiryTest < ApplicationSystemTestCase
  setup do
    @complainant = Complainant.new(
      name: "Test complainant",
      complainant_type: "Consumer",
      phone_number: "01234 567890",
      email_address: "test@example.com"
    )

    @enquiry = Investigation::Enquiry.new(
      user_title: "Enquiry title",
      description: "Enquiry description",
      date_received: "1-1-1",
      received_type: "Email"
    )

    mock_out_keycloak_and_notify
    visit new_enquiry_path
  end

  teardown do
    reset_keycloak_and_notify_mocks
  end

  test "can be reached via create page" do
    visit root_path
    click_on "Create new"
    assert_text "Create new"

    choose "type_enquiry", visible: false
    click_on "Continue"

    assert_text "New enquiry"
  end

  test "complainant type step should be complainant type" do
    fill_about_enquiry_and_continue
    assert_text "New enquiry"
    assert_text "Who did the enquiry come from?"
  end

  test "complainant type step should require an option to be selected" do
    fill_about_enquiry_and_continue
    click_on "Continue"
    assert_text "Select complainant type"
  end

  test "complainant type step should allow a complainant type to be selected" do
    fill_about_enquiry_and_continue
    select_complainant_type_and_continue
    assert_no_text "There is a problem"
  end

  test "complainant details step should be complainant details" do
    fill_about_enquiry_and_continue
    select_complainant_type_and_continue

    assert_text "New enquiry"
    assert_text "What are their contact details?"
  end

  test "complainant details should validate email address" do
    fill_about_enquiry_and_continue
    select_complainant_type_and_continue
    fill_in "complainant[email_address]", with: "invalid_email_address"
    click_on "Continue"

    assert_text "Enter an email address in the correct format, like name@example.com"
  end

  test "complainant details should allow an empty email address" do
    fill_about_enquiry_and_continue
    select_complainant_type_and_continue
    click_on "Continue"

    assert_no_text "There is a problem"
  end

  test "complainant details should allow a valid email address" do
    fill_about_enquiry_and_continue
    select_complainant_type_and_continue
    fill_complainant_details_and_continue

    assert_no_text "There is a problem"
  end

  test "enquiry details should be enquiry details" do
    fill_about_enquiry_and_continue
    select_complainant_type_and_continue
    fill_complainant_details_and_continue

    assert_text "New enquiry"
    assert_text "What is the enquiry?"
  end

  test "enquiry details should require an enquiry title and description" do
    fill_about_enquiry_and_continue
    select_complainant_type_and_continue
    fill_complainant_details_and_continue
    click_on "Create enquiry"

    assert_text "User title can't be blank"
    assert_text "Description can't be blank"
  end

  test "enquiry page should be shown when complete" do
    fill_about_enquiry_and_continue
    select_complainant_type_and_continue
    fill_complainant_details_and_continue
    fill_enquiry_details_and_continue

    assert_current_path(/cases\/\d+/)
    assert_text @enquiry.user_title
  end

  test "confirmation message should be shown when complete" do
    fill_about_enquiry_and_continue
    select_complainant_type_and_continue
    fill_complainant_details_and_continue
    fill_enquiry_details_and_continue

    assert_text "Enquiry was successfully created"
  end

  test "enquiry and complainant details should be logged as case activity" do
    fill_about_enquiry_and_continue
    select_complainant_type_and_continue
    fill_all_complainant_details_and_continue
    fill_enquiry_details_and_continue

    assert_current_path(/cases\/\d+/)
    click_on "Activity"
    assert_text "Enquiry logged: #{@enquiry.title}"
    assert_text @enquiry.description

    assert_text "Name: #{@complainant.name}"
    assert_text "Type: #{@complainant.complainant_type}"
    assert_text "Phone number: #{@complainant.phone_number}"
    assert_text "Email address: #{@complainant.email_address}"
    assert_text @complainant.other_details
  end

  test "related file is attached to the enquiry" do
    attachment_filename = "new_risk_assessment.txt"
    fill_about_enquiry_and_continue
    select_complainant_type_and_continue
    fill_complainant_details_and_continue
    attach_file "enquiry[attachment][file]", Rails.root + "test/fixtures/files/#{attachment_filename}"
    fill_enquiry_details_and_continue

    assert_current_path(/cases\/\d+/)
    click_on "Attachments"

    assert_text attachment_filename
  end

  test "attachment details should be shown in activity entry" do
    attachment_filename = "new_risk_assessment.txt"
    fill_about_enquiry_and_continue
    select_complainant_type_and_continue
    fill_complainant_details_and_continue
    attach_file "enquiry[attachment][file]", Rails.root + "test/fixtures/files/#{attachment_filename}"
    fill_enquiry_details_and_continue

    assert_current_path(/cases\/\d+/)
    click_on "Activity"
    assert_text "Attachment: #{attachment_filename}"
    assert_text "View attachment"
  end

  test "enquiry details should be shown in overview" do
    fill_about_enquiry_and_continue
    select_complainant_type_and_continue
    fill_complainant_details_and_continue
    fill_enquiry_details_and_continue

    assert_no_text "Product category"
    assert_text @complainant.name
  end

  def fill_about_enquiry_and_continue
    fill_in "enquiry[date_received][day]", with: "1"
    fill_in "enquiry[date_received][month]", with: "1"
    fill_in "enquiry[date_received][year]", with: "1"
    choose("enquiry_received_type_email", visible: false, match: :first)
    click_on "Continue"
  end

  def select_complainant_type_and_continue
    choose("complainant[complainant_type]", visible: false, match: :first)
    click_on "Continue"
  end

  def fill_complainant_details_and_continue
    fill_in "complainant[name]", with: @complainant.name
    fill_in "complainant[email_address]", with: @complainant.email_address
    click_on "Continue"
  end

  def fill_all_complainant_details_and_continue
    fill_in "complainant[name]", with: @complainant.name
    fill_in "complainant[phone_number]", with: @complainant.phone_number
    fill_in "complainant[email_address]", with: @complainant.email_address
    fill_in "complainant[other_details]", with: @complainant.other_details
    click_on "Continue"
  end

  def fill_enquiry_details_and_continue
    fill_in "enquiry[user_title]", with: @enquiry.user_title
    fill_in "enquiry[description]", with: @enquiry.description
    click_on "Create enquiry"
  end
end
