require "application_system_test_case"

class InvestigationHighlightTest < ApplicationSystemTestCase
  setup do
    sign_in_as_user
    Investigation.import force: true
  end

  teardown do
    logout
  end

  test "should display highlight title" do
    fill_in "Keywords", with: "234"
    click_on "Search"
    assert_text "234"
    assert_text "Products, gtin"
  end
end
