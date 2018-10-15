require "application_system_test_case"

class InvestigationIncidentTest < ApplicationSystemTestCase

  setup do
    sign_in_as_user
  end

  teardown do
    logout
  end

  test "can add empty incident to investigation" do
    visit new_investigation_incident_path(investigations(:one))
    assert_selector "h1", text: "Add incident"

    click_on "Continue"

    assert_text "Incident was successfully recorded."
  end

  test "can add filled in incident to investigation" do
    visit new_investigation_incident_path(investigations(:one))
    assert_selector "h1", text: "Add incident"

    fill_in "Incident type", with: "Bad Stuff TM"
    fill_in "Incident / event description", with: "Oh, it was horrible"
    fill_in "Day", with: "7"
    fill_in "Month", with: "12"
    fill_in "Year", with: "1984"
    click_on "Continue"

    assert_text "Incident was successfully recorded."
  end
end
