require "application_system_test_case"

class RecordPhoneCallCorrespondenceTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin
    @investigation = investigations(:one)
    @investigation.source = sources(:investigation_one)
    @activity = activities(:one)
    @activity.source = sources(:activity_one)
    visit new_investigation_phone_call_url(@investigation)
  end

  teardown do
    logout
  end

  test "first step should be context" do
    assert_text("Who was the call with?")
  end

  test "first step validates date" do
    fill_in("correspondence[day]", with: "333")
    click_on "Continue"
    assert_text("Must be a valid date")
  end

  test "second step should be content" do
    click_button "Continue"
    assert_text("Give an overview of the phonecall")
  end

  test "attaches a transcript file" do
    click_button "Continue"
    attach_file("correspondence[file][file]", Rails.root + "test/fixtures/files/testImage.png")
    click_button "Continue"
    assert_text("testImage")
    click_button "Continue"
    click_on "Full detail"
    assert_text("testImage")
  end

  test "third step should be confirmation" do
    click_button "Continue"
    click_button "Continue"
    assert_text "Confirm phonecall details"
    assert_text "Attachments"
  end

  test "confirmation edit details should go to first page in flow" do
    click_button "Continue"
    click_button "Continue"
    click_on "Edit details"
    assert_text "Who was the call with?"
  end

  test "edit details should retain changed values" do
    fill_in("correspondence[correspondent_name]", with: "Tom")
    fill_in("correspondence[phone_number]", with: "012345678910")
    click_button "Continue"
    click_button "Continue"
    click_on "Edit details"
    assert_equal('Tom', find_field('correspondence[correspondent_name]').value)
    assert_not_equal('', find_field('correspondence[correspondent_name]').value)
    assert_equal('012345678910', find_field('correspondence[phone_number]').value)
    assert_not_equal('', find_field('correspondence[phone_number]').value)
  end

  test "confirmation continue should go to case page" do
    visit new_investigation_phone_call_url(investigations(:no_products))
    click_button "Continue"
    click_button "Continue"
    click_button "Continue"
    assert_text("There are no products attached to this case")
  end
end
