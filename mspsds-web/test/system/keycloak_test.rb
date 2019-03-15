require "application_system_test_case"

class KeycloakTest < ApplicationSystemTestCase
  test "can login" do
    visit root_path
    sign_in email: "admin@example.com", password: "password"
    assert_current_path root_path
    assert_selector "a", text: "Sign out"
  end

  test "can logout" do
    visit root_path
    sign_in email: "admin@example.com", password: "password"
    click_on "Sign out"
    assert_selector "h1", text: "Sign in to Market Surveillance & Product Safety"
  end

  test "redirects to previous page after login" do
    visit products_path
    sign_in email: "admin@example.com", password: "password"
    assert_current_path products_path
  end

  def sign_in(email:, password:)
    assert_selector "h1", text: "Sign in to Market Surveillance & Product Safety"
    fill_in "Email address", with: email
    fill_in "Password", with: password
    click_on "Continue"
  end
end
