require "application_system_test_case"

class HazardsTest < ApplicationSystemTestCase
  setup do
    @hazard = hazards(:one)
  end

  test "visiting the index" do
    visit hazards_url
    assert_selector "h1", text: "Hazards"
  end

  test "creating a Hazard" do
    visit hazards_url
    click_on "New Hazard"

    fill_in "Affected Parties", with: @hazard.affected_parties
    fill_in "Description", with: @hazard.description
    fill_in "Hazard Type", with: @hazard.hazard_type
    fill_in "Investigation", with: @hazard.investigation
    fill_in "Risk Level", with: @hazard.risk_level
    click_on "Create Hazard"

    assert_text "Hazard was successfully created"
    click_on "Back"
  end

  test "updating a Hazard" do
    visit hazards_url
    click_on "Edit", match: :first

    fill_in "Affected Parties", with: @hazard.affected_parties
    fill_in "Description", with: @hazard.description
    fill_in "Hazard Type", with: @hazard.hazard_type
    fill_in "Investigation", with: @hazard.investigation
    fill_in "Risk Level", with: @hazard.risk_level
    click_on "Update Hazard"

    assert_text "Hazard was successfully updated"
    click_on "Back"
  end

  test "destroying a Hazard" do
    visit hazards_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Hazard was successfully destroyed"
  end
end
