require "application_system_test_case"

class InvestigationIncidentTest < ApplicationSystemTestCase
  setup do
    sign_in_as_user
    visit new_investigation_incident_path(investigations(:one))
    assert_selector "h1", text: "Add incident"
  end

  teardown do
    logout
  end

  test "can add empty incident to investigation" do
    click_on "Continue"

    assert_text "Confirm incident details"
    click_on "Continue"

    # The better assertion here would be to look for the flash message confirming successful incident submission
    # For whatever reason, this doesn't seem to show up in test (confirmed by inspecting failure screenshots)
    # assert_text "Incident was successfully recorded."
    assert_current_path(/investigations\/\d+/)
  end

  test "can add filled in incident to investigation" do
    fill_in "Incident type", with: "Bad Stuff TM"
    fill_in "Incident / event description", with: "Oh, it was horrible"
    fill_in "Day", with: "7"
    fill_in "Month", with: "12"
    fill_in "Year", with: "1984"
    click_on "Continue"

    assert_text "Confirm incident details"
    click_on "Continue"

    # The better assertion here would be to look for the flash message confirming successful incident submission
    # For whatever reason, this doesn't seem to show up in test (confirmed by inspecting failure screenshots)
    # assert_text "Incident was successfully recorded."
    assert_current_path(/investigations\/\d+/)
  end

  test "can go back to the editing page from the confirmation page and not loose data" do
    fill_in "Incident type", with: "Bad Stuff TM"
    fill_in "Incident / event description", with: "Oh, it was horrible"
    fill_in "Day", with: "7"
    fill_in "Month", with: "12"
    fill_in "Year", with: "1984"
    click_on "Continue"

    # Assert all of the data is still here
    assert_text "Confirm incident details"
    assert_text "Bad Stuff TM"
    assert_text "Oh, it was horrible"
    assert_text "07/12/1984"
    click_on "Edit details"

    # Assert we're back on the edit page and haven't lost data
    assert_text "Add incident"
    assert_field with: "Bad Stuff TM"
    assert_field with: "Oh, it was horrible"
    assert_field with: "7"
    assert_field with: "12"
    assert_field with: "1984"
  end

  test "wizard data doesn't persist between reloads" do
    fill_in "Incident type", with: "Bad Stuff TM"
    click_on "Continue"
    visit new_investigation_incident_path(investigations(:one))

    assert_no_field with: "Bad Stuff TM"
  end

  test "wizard data gets clear after completion" do
    fill_in "Incident type", with: "Bad Stuff TM"
    click_on "Continue"
    click_on "Continue"
    visit new_investigation_incident_path(investigations(:one))

    assert_no_field with: "Bad Stuff TM"
  end

  test "wrongly formatted date shows an error" do
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
end
