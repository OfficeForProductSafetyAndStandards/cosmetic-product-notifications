require "application_system_test_case"

class KeycloakTest < ApplicationSystemTestCase
  setup do
    sign_out_if_signed_in
  end

  teardown do
    sign_out_if_signed_in
  end

  test "can login" do
    visit root_url
    sign_in email: "user@example.com", password: "password"
    assert_text "Sign out"
  end

  test "can logout" do
    visit root_url
    sign_in email: "user@example.com", password: "password"
    click_on "Sign out"
    assert_selector "h1", text: "Sign in to Product safety database"
  end

  test "redirects to previous page after login" do
    visit products_url
    sign_in email: "user@example.com", password: "password"
    assert_current_path declaration_index_path(redirect_path: products_path)
  end

  def sign_in(email:, password:)
    assert_selector "h1", text: "Sign in to Product safety database"
    fill_in "Email address", with: email
    fill_in "Password", with: password
    click_on "Continue"
  end

  def sign_out_if_signed_in
    click_link('Sign out') if has_link?('Sign out')
  end
end
