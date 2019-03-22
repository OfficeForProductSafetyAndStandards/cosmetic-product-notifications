require "application_system_test_case"

class IntroductionTest < ApplicationSystemTestCase
  setup do
    mock_out_keycloak_and_notify
    mock_user_as_non_opss User.current

    visit '/'
  end

  teardown do
    reset_keycloak_and_notify_mocks
  end

  test "shows steps in order then redirects to homepage" do
    assert_current_path '/introduction/overview'
    assert_selector "h1", text: "Report, track and share product safety information"
    click_on "Continue"

    assert_current_path "/introduction/report_products"
    click_on "Continue"

    assert_current_path "/introduction/track_investigations"
    click_on "Continue"

    assert_current_path "/introduction/share_data"
    click_on "Get started"

    assert_text "Open a new case"
    assert_current_path "/"
  end

  test "clicking skip introduction skips introduction" do
    click_on "Skip introduction"

    assert_current_path "/"
  end

  test "users will not be shown the introduction twice" do
    assert_current_path '/introduction/overview'
    click_on "Continue"
    click_on "Continue"
    click_on "Continue"
    click_on "Get started"
    visit '/'
    assert_current_path '/'
  end

  test "does not show introduction to opss users" do
    mock_user_as_opss User.current

    visit '/'

    assert_current_path "/cases"
  end
end
