require "application_system_test_case"

class CreateQuestionTest < ApplicationSystemTestCase
  setup do
    sign_in_as_user
    visit new_question_path
  end

  teardown do
    logout
  end

  test "can be reached via create page" do
    visit root_path
    click_on "Create new"
    assert_text "Create new"

    choose "type_question", visible: false
    click_on "Continue"

    assert_text "New Question"
  end

  test "first step should be reporter type" do
    assert_text "New Question"
    assert_text "Who did the question come from?"
  end

  test "first step should require an option to be selected" do
    click_on "Continue"
    assert_text "Reporter type can't be blank"
  end

  test "first step should allow a reporter type to be selected" do
    select_reporter_type_and_continue
    assert_no_text "prevented this reporter from being saved"
  end

  test "second step should be reporter details" do
    select_reporter_type_and_continue

    assert_text "New Question"
    assert_text "What are their contact details?"
  end

  test "second step should validate email address" do
    select_reporter_type_and_continue
    fill_in "reporter[email_address]", with: "invalid_email_address"
    click_on "Continue"

    assert_text "Email address is invalid"
  end

  test "second step should allow an empty email address" do
    select_reporter_type_and_continue
    click_on "Continue"

    assert_no_text "prevented this reporter from being saved"
  end

  test "second step should allow a valid email address" do
    select_reporter_type_and_continue
    fill_reporter_details_and_continue

    assert_no_text "prevented this reporter from being saved"
  end

  test "third step should be question details" do
    select_reporter_type_and_continue
    fill_reporter_details_and_continue

    assert_text "New Question"
    assert_text "What is the question?"
  end

  test "third step should require a question title and description" do
    select_reporter_type_and_continue
    fill_reporter_details_and_continue
    click_on "Continue"

    assert_text "Question title can't be blank"
    assert_text "Description can't be blank"
  end

  test "question page should be shown when complete" do
    select_reporter_type_and_continue
    fill_reporter_details_and_continue
    fill_question_details_and_continue

    assert_current_path(/cases\/\d+/)
    assert_text "Test question title"
    assert_text "Test description"
  end

  test "confirmation message should be shown when complete" do
    select_reporter_type_and_continue
    fill_reporter_details_and_continue
    fill_question_details_and_continue

    assert_text "Question was successfully created"
  end

  test "related file is attached to the question" do
    attachment_filename = "new_risk_assessment.txt"

    select_reporter_type_and_continue
    fill_reporter_details_and_continue
    attach_file "question[attachment][file]", Rails.root + "test/fixtures/files/#{attachment_filename}"
    fill_question_details_and_continue

    assert_current_path(/cases\/\d+/)
    click_on "Attachments"

    assert_text attachment_filename
  end

  def select_reporter_type_and_continue
    choose("reporter[reporter_type]", visible: false, match: :first)
    click_on "Continue"
  end

  def fill_reporter_details_and_continue
    fill_in "reporter[email_address]", with: "test@example.com"
    click_on "Continue"
  end

  def fill_question_details_and_continue
    fill_in "question[question_title]", with: "Test question title"
    fill_in "question[description]", with: "Test description"
    click_on "Continue"
  end
end
