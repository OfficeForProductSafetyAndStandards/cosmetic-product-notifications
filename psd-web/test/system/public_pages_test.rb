require "application_system_test_case"

class PublicPagesHelper < ApplicationSystemTestCase
  test "Should allow to see terms and conditions when not logged in" do
    visit help_terms_and_conditions_path
    assert_current_path(/help\/terms-and-conditions/)
  end

  test "Should allow to see about page when not logged in" do
    visit help_about_path
    assert_current_path(/help\/about/)
  end

  test "Should allow to see privacy notice page when not logged in" do
    visit help_privacy_notice_path
    assert_current_path(/help\/privacy-notice/)
  end
end
