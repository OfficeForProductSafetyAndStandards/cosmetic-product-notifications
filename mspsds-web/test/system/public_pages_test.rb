require "application_system_test_case"

class PublicPagesHelper < ApplicationSystemTestCase
  test "Should allow to see terms and conditions when not logged in" do
    visit "/terms-and-conditions"
    assert_current_path(/terms-and-conditions/)
  end

  test "Should allow to see about page when not logged in" do
    visit "/about"
    assert_current_path(/about/)
  end

  test "Should allow to see privacy policy page when not logged in" do
    visit "/privacy-policy"
    assert_current_path(/privacy-policy/)
  end
end
