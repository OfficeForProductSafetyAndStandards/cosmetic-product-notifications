require "application_system_test_case"

class InvestigationTestRequestTest < ApplicationSystemTestCase
  setup do
    sign_in_as_user

    @investigation = investigations(:one)
    @test = tests(:one)

    visit new_request_investigation_tests_path(@investigation)
    assert_selector "h1", text: "Record testing request"
  end

  teardown do
    logout
  end

  test "cannot add test request without a date" do
    click_button "Continue"

    assert_text "The following errors prevented this testing request from being saved"
    assert_text "Date can't be blank"
  end

  test "can add filled in test request to investigation" do
    fill_in_basic_details
    click_on "Continue"

    assert_text "Confirm testing request details"
    click_on "Continue"

    assert_current_path(/cases\/\d+/)
    assert_text "Test requested: #{@test.product.name}"
    assert_text "Testing requested"
  end

  test "can go back to the edit page from the confirmation page and not lose data" do
    fill_in_basic_details
    click_on "Continue"

    # Assert all of the data is still here
    assert_text @test.legislation
    assert_text @test.details
    assert_text "08/11/2018"
    click_on "Edit details"

    # Assert we're back on the details page and haven't lost data
    assert_text "Record testing request"
    assert_field with: @test.legislation
    assert_field with: @test.details
    assert_field with: @test.date.day
    assert_field with: @test.date.month
    assert_field with: @test.date.year
  end

  test "session data doesn't persist between reloads" do
    fill_in_basic_details
    visit new_request_investigation_tests_path(@investigation)

    assert_no_field with: @test.legislation
  end

  test "session data is cleared after completion" do
    fill_in_basic_details
    click_on "Continue"
    click_on "Continue"

    visit new_request_investigation_tests_path(@investigation)

    assert_no_field with: @test.legislation
  end

  test "invalid date shows an error" do
    fill_in "Day", with: "7"
    fill_in "Month", with: "13"
    fill_in "Year", with: "1984"
    click_on "Continue"

    assert_text("Date must be a valid date")
  end

  test "date with missing component shows an error" do
    fill_in "Day", with: "7"
    fill_in "Year", with: "1984"
    click_on "Continue"

    assert_text("Date must specify a day, month and year")
  end

  test "can add an attachment to the test request" do
    attachment_filename = "new_risk_assessment.txt"
    attachment_description = "Test attachment description"

    fill_in_basic_details
    attach_file "test[file][file]", Rails.root + "test/fixtures/files/#{attachment_filename}"
    fill_in "Attachment description", with: attachment_description
    click_on "Continue"

    assert_text "Confirm testing request details"
    assert_text attachment_filename
    assert_text attachment_description
    click_on "Continue"

    assert_current_path(/cases\/\d+/)
    assert_text "Attached: #{attachment_filename}"
    assert_text "View attachment"
  end

  test "attachment description field is not visible when no file is selected" do
    assert_no_text "Attachment description"
  end

  test "attachment description field is visible when a file is selected" do
    attach_file "test[file][file]", Rails.root + "test/fixtures/files/new_risk_assessment.txt"

    assert_text "Attachment description"
  end

  def fill_in_basic_details
    fill_autocomplete "product-picker", with: @test.product.name
    fill_autocomplete "legislation-picker", with: @test.legislation
    fill_in "test_details", with: @test.details
    fill_in "Day", with: @test.date.day
    fill_in "Month", with: @test.date.month
    fill_in "Year", with: @test.date.year
  end
end
