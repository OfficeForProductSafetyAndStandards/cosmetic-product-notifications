require "application_system_test_case"

class CreateAllegationTest < ApplicationSystemTestCase
  setup do
    @complainant = Complainant.new(
      name: "Test complainant",
      complainant_type: "Consumer",
      phone_number: "01234 567890",
      email_address: "test@example.com"
    )

    @allegation = Investigation::Allegation.new(
      hazard_type: "Blunt force",
      product_category: "Small Electronics",
      description: "Allegation description"
    )

    mock_out_keycloak_and_notify
    visit new_allegation_path
  end

  teardown do
    reset_keycloak_and_notify_mocks
  end

  test "can be reached via create page" do
    visit root_path
    click_on "Create new"
    assert_text "Create new"

    choose "type_allegation", visible: false
    click_on "Continue"

    assert_text "New Allegation"
  end

  test "first step should be complainant type" do
    assert_text "New Allegation"
    assert_text "Who's making the allegation?"
  end

  test "first step should require an option to be selected" do
    click_on "Continue"
    assert_text "Select complainant type"
  end

  test "first step should allow a complainant type to be selected" do
    select_complainant_type_and_continue
    assert_no_text "There is a problem"
  end

  test "second step should be complainant details" do
    select_complainant_type_and_continue

    assert_text "New Allegation"
    assert_text "What are their contact details?"
  end

  test "second step should validate email address" do
    select_complainant_type_and_continue
    fill_in "complainant[email_address]", with: "invalid_email_address"
    click_on "Continue"

    assert_text "Enter a real email address"
  end

  test "second step should allow an empty email address" do
    select_complainant_type_and_continue
    click_on "Continue"

    assert_no_text "There is a problem"
  end

  test "second step should allow a valid email address" do
    select_complainant_type_and_continue
    fill_complainant_details_and_continue

    assert_no_text "There is a problem"
  end

  test "third step should be allegation details" do
    select_complainant_type_and_continue
    fill_complainant_details_and_continue

    assert_text "New Allegation"
    assert_text "What is being alleged?"
  end

  test "third step should require a description" do
    select_complainant_type_and_continue
    fill_complainant_details_and_continue
    click_on "Create allegation"

    assert_text "Enter description"
  end

  test "third step should require a product type and hazard type to be selected" do
    select_complainant_type_and_continue
    fill_complainant_details_and_continue
    click_on "Create allegation"

    assert_text "Enter product category"
    assert_text "Enter hazard type"
  end

  test "case page should be shown when complete" do
    select_complainant_type_and_continue
    fill_complainant_details_and_continue
    fill_allegation_details_and_continue

    assert_current_path(/cases\/\d+/)
  end

  test "confirmation message should be shown when complete" do
    select_complainant_type_and_continue
    fill_complainant_details_and_continue
    fill_allegation_details_and_continue

    assert_text "Allegation was successfully created"
  end

  test "allegation and complainant details should be logged as case activity" do
    select_complainant_type_and_continue
    fill_all_complainant_details_and_continue
    fill_allegation_details_and_continue

    assert_current_path(/cases\/\d+/)
    click_on "Activity"

    assert_text "Allegation logged: #{@allegation.title}"
    assert_text "Product category: #{@allegation.product_category}"
    assert_text "Hazard type: #{@allegation.hazard_type}"
    assert_text @allegation.description

    assert_text "Name: #{@complainant.name}"
    assert_text "Type: #{@complainant.complainant_type}"
    assert_text "Phone number: #{@complainant.phone_number}"
    assert_text "Email address: #{@complainant.email_address}"
    assert_text @complainant.other_details
  end

  test "related file is attached to the case" do
    attachment_filename = "new_risk_assessment.txt"

    select_complainant_type_and_continue
    fill_complainant_details_and_continue
    attach_file "allegation[attachment][file]", Rails.root + "test/fixtures/files/#{attachment_filename}"
    fill_allegation_details_and_continue

    assert_current_path(/cases\/\d+/)
    click_on "Attachments"

    assert_text attachment_filename
  end

  test "attachment details should be shown in activity entry" do
    attachment_filename = "new_risk_assessment.txt"

    select_complainant_type_and_continue
    fill_complainant_details_and_continue
    attach_file "allegation[attachment][file]", Rails.root + "test/fixtures/files/#{attachment_filename}"
    fill_allegation_details_and_continue

    assert_current_path(/cases\/\d+/)
    click_on "Activity"
    assert_text "Attachment: #{attachment_filename}"
    assert_text "View attachment"
  end

  test "allegation details should be shown in overview" do
    select_complainant_type_and_continue
    fill_complainant_details_and_continue
    fill_allegation_details_and_continue

    assert_text @allegation.product_category
    assert_text @complainant.name
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

  def fill_allegation_details_and_continue
    fill_in "allegation[description]", with: @allegation.description
    fill_autocomplete "picker-hazard_type", with: @allegation.hazard_type
    fill_autocomplete "picker-product_category", with: @allegation.product_category
    click_on "Create allegation"
  end
end
