require "application_system_test_case"

class CreateAllegationTest < ApplicationSystemTestCase
  setup do
    @reporter = Reporter.new(
      name: "Test Reporter",
      reporter_type: "Consumer",
      phone_number: "01234 567890",
      email_address: "test@example.com"
    )

    @allegation = Investigation.new(
      hazard_type: "Blunt force",
      product_category: "Small Electronics",
      description: "Allegation description"
    )

    sign_in_as_user
    visit new_allegation_path
  end

  teardown do
    logout
  end

  test "can be reached via create page" do
    visit root_path
    click_on "Create new"
    assert_text "Create new"

    choose "type_allegation", visible: false
    click_on "Continue"

    assert_text "New Allegation"
  end

  test "first step should be reporter type" do
    assert_text "New Allegation"
    assert_text "Who's making the allegation?"
  end

  test "first step should require an option to be selected" do
    click_on "Continue"
    assert_text "Reporter type can't be blank"
  end

  test "first step should allow a reporter type to be selected" do
    select_reporter_type_and_continue
    assert_no_text "prevented this reporter from being saved"
  end

  test "second step should be reporter details" do
    select_reporter_type_and_continue

    assert_text "New Allegation"
    assert_text "What are their contact details?"
  end

  test "second step should validate email address" do
    select_reporter_type_and_continue
    fill_in "reporter[email_address]", with: "invalid_email_address"
    click_on "Continue"

    assert_text "Email address is invalid"
  end

  test "second step should allow an empty email address" do
    select_reporter_type_and_continue
    click_on "Continue"

    assert_no_text "prevented this reporter from being saved"
  end

  test "second step should allow a valid email address" do
    select_reporter_type_and_continue
    fill_reporter_details_and_continue

    assert_no_text "prevented this reporter from being saved"
  end

  test "third step should be allegation details" do
    select_reporter_type_and_continue
    fill_reporter_details_and_continue

    assert_text "New Allegation"
    assert_text "What is being alleged?"
  end

  test "third step should require a description" do
    select_reporter_type_and_continue
    fill_reporter_details_and_continue
    click_on "Continue"

    assert_text "Description can't be blank"
  end

  test "third step should require a product type and hazard type to be selected" do
    select_reporter_type_and_continue
    fill_reporter_details_and_continue
    click_on "Continue"

    assert_text "Product category can't be blank"
    assert_text "Hazard type can't be blank"
  end

  test "case page should be shown when complete" do
    select_reporter_type_and_continue
    fill_reporter_details_and_continue
    fill_allegation_details_and_continue

    assert_current_path(/cases\/\d+/)
  end

  test "confirmation message should be shown when complete" do
    select_reporter_type_and_continue
    fill_reporter_details_and_continue
    fill_allegation_details_and_continue

    assert_text "Allegation was successfully created"
  end

  test "allegation and reporter details should be logged as case activity" do
    select_reporter_type_and_continue
    fill_all_reporter_details_and_continue
    fill_allegation_details_and_continue

    assert_current_path(/cases\/\d+/)

    assert_text "Allegation logged: #{@allegation.title}"
    assert_text "Product category: #{@allegation.product_category}"
    assert_text "Hazard type: #{@allegation.hazard_type}"
    assert_text @allegation.description

    assert_text "Name: #{@reporter.name}"
    assert_text "Type: #{@reporter.reporter_type}"
    assert_text "Phone number: #{@reporter.phone_number}"
    assert_text "Email address: #{@reporter.email_address}"
    assert_text @reporter.other_details
  end

  test "related file is attached to the case" do
    attachment_filename = "new_risk_assessment.txt"

    select_reporter_type_and_continue
    fill_reporter_details_and_continue
    attach_file "allegation[attachment][file]", Rails.root + "test/fixtures/files/#{attachment_filename}"
    fill_allegation_details_and_continue

    assert_current_path(/cases\/\d+/)
    click_on "Attachments"

    assert_text attachment_filename
  end

  test "attachment details should be shown in activity entry" do
    attachment_filename = "new_risk_assessment.txt"

    select_reporter_type_and_continue
    fill_reporter_details_and_continue
    attach_file "allegation[attachment][file]", Rails.root + "test/fixtures/files/#{attachment_filename}"
    fill_allegation_details_and_continue

    assert_current_path(/cases\/\d+/)

    assert_text "Attachment: #{attachment_filename}"
    assert_text "View attachment"
  end

  def select_reporter_type_and_continue
    choose("reporter[reporter_type]", visible: false, match: :first)
    click_on "Continue"
  end

  def fill_reporter_details_and_continue
    fill_in "reporter[name]", with: @reporter.name
    fill_in "reporter[email_address]", with: @reporter.email_address
    click_on "Continue"
  end

  def fill_all_reporter_details_and_continue
    fill_in "reporter[name]", with: @reporter.name
    fill_in "reporter[phone_number]", with: @reporter.phone_number
    fill_in "reporter[email_address]", with: @reporter.email_address
    fill_in "reporter[other_details]", with: @reporter.other_details
    click_on "Continue"
  end

  def fill_allegation_details_and_continue
    fill_in "allegation[description]", with: @allegation.description
    fill_autocomplete "hazard-type-picker", with: @allegation.hazard_type
    fill_autocomplete "product-category-picker", with: @allegation.product_category
    click_on "Continue"
  end
end
