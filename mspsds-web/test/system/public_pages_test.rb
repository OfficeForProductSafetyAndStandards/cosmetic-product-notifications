require "application_system_test_case"

class PublicPagesHelper < ApplicationSystemTestCase
  setup do
  end

  teardown do
    reset_keycloak_and_notify_mocks
  end

  test "Should allow to see terms and conditions when not logged in" do
    visit "/terms_and_conditions"
    assert_current_path(/terms_and_conditions/)
  end

  test "Should allow to see about page when not logged in" do
    visit "/about"
    assert_current_path(/about/)
  end
end
