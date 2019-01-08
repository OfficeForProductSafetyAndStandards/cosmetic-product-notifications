require "application_system_test_case"

class ActivityEntryTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin_with_organisation
    @investigation = investigations(:one)
    visit investigation_path(@investigation)
    click_on "Add activity"
  end

  teardown do
    logout
  end

  test "Should go to an activity selection page" do
    assert_text "New activity"
  end

  test "Should require picking an activity type" do
    click_on "Continue"
    assert_text "Activity type must not be empty"
  end
end
