require "application_system_test_case"

class InvestigationsTest < ApplicationSystemTestCase
  setup do
    @investigation = investigations(:one)
  end

  test "visiting the index" do
    visit investigations_url
    assert_selector "h1", text: "Investigations"
  end

  test "creating a Investigation" do
    visit investigations_url
    click_on "New Investigation"

    fill_in "Description", with: @investigation.description
    fill_in "Is Closed", with: @investigation.is_closed
    fill_in "Product", with: @investigation.product_id
    fill_in "Severity", with: @investigation.severity
    fill_in "Source", with: @investigation.source
    click_on "Create Investigation"

    assert_text "Investigation was successfully created"
    click_on "Back"
  end

  test "updating a Investigation" do
    visit investigations_url
    click_on "Edit", match: :first

    fill_in "Description", with: @investigation.description
    fill_in "Is Closed", with: @investigation.is_closed
    fill_in "Product", with: @investigation.product_id
    fill_in "Severity", with: @investigation.severity
    fill_in "Source", with: @investigation.source
    click_on "Update Investigation"

    assert_text "Investigation was successfully updated"
    click_on "Back"
  end

  test "destroying a Investigation" do
    visit investigations_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Investigation was successfully destroyed"
  end
end
