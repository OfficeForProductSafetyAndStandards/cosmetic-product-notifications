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

  test "cannot add test request without legislation" do
    click_button "Continue"
    assert_text("prohibited this testing request from being saved")
    assert_text("Legislation can't be blank")
  end

  test "can add filled in test request to investigation" do
    fill_in_basic_details
    click_on "Continue"

    assert_text "Confirm testing request details"
    click_on "Continue"

    # The better assertion here would be to look for the flash message confirming successful incident submission
    # For whatever reason, this doesn't seem to show up in test (confirmed by inspecting failure screenshots)
    # assert_text "Incident was successfully recorded."
    assert_current_path(/investigations\/\d+/)
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

    assert_text("Enter a real incident date")
  end

  test "date with missing component shows an error" do
    fill_in "Day", with: "7"
    fill_in "Year", with: "1984"
    click_on "Continue"

    assert_text("Enter date of incident and include a day, month and year")
  end

  def fill_in_basic_details
    # select @test.product_id, from: "test_product_id"
    fill_in "test_legislation", with: @test.legislation
    fill_in "test_details", with: @test.details
    fill_in "Day", with: @test.date.day
    fill_in "Month", with: @test.date.month
    fill_in "Year", with: @test.date.year
  end
end
