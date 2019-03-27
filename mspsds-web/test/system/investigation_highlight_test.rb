require "application_system_test_case"

class InvestigationHighlightTest < ApplicationSystemTestCase
  setup do
    mock_out_keycloak_and_notify
    accept_declaration
    visit root_path
  end

  teardown do
    reset_keycloak_and_notify_mocks
  end

  test "should display highlight title" do
    fill_in "q", with: "234", visible: false
    click_on "Search"
    assert_text "234"
    assert_text "Products, product code"
  end
end
