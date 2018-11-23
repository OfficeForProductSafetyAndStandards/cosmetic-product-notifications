require "application_system_test_case"

class RecordEmailCorrespondenceTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin
    @investigation = investigations(:one)
    @investigation.source = sources(:investigation_one)
    @activity = activities(:one)
    @activity.source = sources(:activity_one)
    visit new_investigation_email_url(@investigation)
  end

  teardown do
    logout
  end

  test "first step should be context" do
    assert_text("Email details")
  end

  test "first step validates date" do
    fill_in("correspondence[day]", with: "333")
    click_on "Continue"
    assert_text("Correspondence date must be a valid date")
  end

  test "second step should be content" do
    click_button "Continue"
    assert_text("Email content")
  end

  test "attaches the email file" do
    click_button "Continue"
    attach_file("correspondence[email_file][file]", Rails.root + "test/fixtures/files/testImage.png")
    click_button "Continue"
    assert_text("testImage")
    click_button "Continue"
    click_on "Full detail"
    assert_text("testImage")
  end

  test "attaches the email attachment" do
    click_button "Continue"
    attach_file("correspondence[email_attachment][file]", Rails.root + "test/fixtures/files/testImage2.png")
    click_button "Continue"
    assert_text("testImage2")
    click_button "Continue"
    click_on "Full detail"
    assert_text("testImage")
  end

  test "third step should be confirmation" do
    click_button "Continue"
    click_button "Continue"
    assert_text "Confirm email details"
    assert_text "Attachments"
  end

  test "confirmation edit details should go to first page in flow" do
    click_button "Continue"
    click_button "Continue"
    click_on "Edit details"
    assert_text "Email details"
    assert_no_text "attachment"
  end

  test "edit details should retain changed values" do
    fill_in("correspondence[correspondent_name]", with: "Tom")
    click_button "Continue"
    click_button "Continue"
    click_on "Edit details"
    assert_equal('Tom', find_field('correspondence[correspondent_name]').value)
    assert_not_equal('', find_field('correspondence[correspondent_name]').value)
  end

  test "confirmation continue should go to case page" do
    visit new_investigation_email_url(investigations(:no_products))
    click_button "Continue"
    click_button "Continue"
    click_button "Continue"
    assert_text("There are no products attached to this case")
  end
end
