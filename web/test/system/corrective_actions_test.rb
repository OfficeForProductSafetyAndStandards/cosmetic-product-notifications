require "application_system_test_case"

class CorrectiveActionsTest < ApplicationSystemTestCase
  setup do
    @corrective_action = corrective_actions(:one)
  end

  test "visiting the index" do
    visit corrective_actions_url
    assert_selector "h1", text: "Corrective Actions"
  end

  test "creating a Corrective action" do
    visit corrective_actions_url
    click_on "New Corrective Action"

    fill_in "Business", with: @corrective_action.business_id
    fill_in "Date Decided", with: @corrective_action.date_decided
    fill_in "Details", with: @corrective_action.details
    fill_in "Investigation", with: @corrective_action.investigation_id
    fill_in "Legislation", with: @corrective_action.legislation
    fill_in "Product", with: @corrective_action.product_id
    fill_in "Summary", with: @corrective_action.summary
    click_on "Create Corrective action"

    assert_text "Corrective action was successfully created"
    click_on "Back"
  end

  test "updating a Corrective action" do
    visit corrective_actions_url
    click_on "Edit", match: :first

    fill_in "Business", with: @corrective_action.business_id
    fill_in "Date Decided", with: @corrective_action.date_decided
    fill_in "Details", with: @corrective_action.details
    fill_in "Investigation", with: @corrective_action.investigation_id
    fill_in "Legislation", with: @corrective_action.legislation
    fill_in "Product", with: @corrective_action.product_id
    fill_in "Summary", with: @corrective_action.summary
    click_on "Update Corrective action"

    assert_text "Corrective action was successfully updated"
    click_on "Back"
  end

  test "destroying a Corrective action" do
    visit corrective_actions_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Corrective action was successfully destroyed"
  end
end
