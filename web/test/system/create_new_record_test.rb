require "application_system_test_case"

class CreateNewRecordTest < ApplicationSystemTestCase
  setup do
    sign_in_as_user
    visit new_investigation_path
  end

  teardown do
    logout
  end

  test "can be reached via home page" do
    visit root_path
    click_on "Create new"

    assert_text "Create new"
  end

  test "should be prompted to select what to create" do
    assert_text "Product safety allegation"
    assert_text "Question"
    assert_text "Product recall notification"
    assert_text "Notification from RAPEX"

    assert_no_text "Please select an option before continuing"
  end

  test "should require an option to be selected" do
    click_on "Continue"

    assert_text "Please select an option before continuing"
  end

  test "should show the new question page when selecting question" do
    choose "type_question", visible: false
    click_on "Continue"

    assert_text "New Question"
  end
end
