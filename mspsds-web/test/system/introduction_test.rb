require "application_system_test_case"

class IntroductionTest < ApplicationSystemTestCase
  setup do
    @user = mock_out_keycloak_and_notify
    set_user_as_non_opss(@user)

    visit '/'
  end

  teardown do
    reset_keycloak_and_notify_mocks
  end

  test "shows steps in order then redirects to homepage" do
    assert_current_path '/introduction/overview'
    assert_selector "h1", text: "Report, track and share product safety information"
    click_on "Continue"

    assert_selector "h1", text: "Report unsafe and non-compliant products"
    click_on "Continue"

    assert_selector "h1", text: "Track and manage investigations"
    click_on "Continue"

    assert_selector "h1", text: "Share national data on products, incidents and businesses"
    click_on "Get started"

    assert_text "Open a new case"
    assert_current_path "/"
  end

  test "clicking skip introduction skips introduction" do
    click_on "Skip introduction"

    assert_current_path "/"
  end

  test "users will not be shown the introduction twice" do
    assert_selector "h1", text: "Report, track and share product safety information"

    visit '/'

    assert_current_path "/"
  end

  test "does not show introduction to opss users" do
    set_user_as_opss @user

    visit '/'

    assert_current_path "/cases"
  end
end
