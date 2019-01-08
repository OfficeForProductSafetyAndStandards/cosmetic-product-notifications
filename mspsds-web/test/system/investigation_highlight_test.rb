require "application_system_test_case"

class InvestigationHighlightTest < ApplicationSystemTestCase
  setup do
    sign_in_as_office_user
    visit root_path
  end

  teardown do
    logout
  end

  test "should display highlight title" do
    fill_in "q", with: "234", visible: false
    click_on "Search"
    assert_text "234"
    assert_text "Products, gtin"
  end
end
