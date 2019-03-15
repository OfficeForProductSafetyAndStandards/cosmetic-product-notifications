require "application_system_test_case"

class ActivityEntryTest < ApplicationSystemTestCase
  setup do
    mock_out_keycloak_and_notify(user_name: "Admin")
    @investigation = investigations(:one)
    visit investigation_path(@investigation)
    click_on "Add activity"
  end

  teardown do
    reset_keycloak_and_notify_mocks
  end

  test "Should go to an activity selection page" do
    assert_text "New activity"
  end

  test "Should require picking an activity type" do
    click_on "Continue"
    assert_text "Activity type must not be empty"
  end
end
