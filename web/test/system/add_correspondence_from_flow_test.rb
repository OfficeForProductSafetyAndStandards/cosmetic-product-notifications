require "application_system_test_case"

class AddCorrespondenceFromFlowTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin
    @investigation = investigations(:one)
    @investigation.source = sources(:investigation_one)
    @activity = activities(:one)
    @activity.source = sources(:activity_one)

    @reporter = Reporter.create(
      reporter_type: "Consumer",
      name: "Test Reporter",
      email_address: "test.reporter@example.com"
    )
    @investigation_with_reporter = investigations(:two)
    @investigation_with_reporter.reporter = @reporter

    visit new_investigation_correspondence_url(@investigation)
  end

  teardown do
    logout
  end

  test "first step should be general info" do
    assert_text("Who is the correspondence with?")
  end

  test "first step should validate date" do
    fill_in("correspondence[day]", with: "333")
    click_on "Continue"
    assert_text("prevented this item from being saved")
  end

  test "first step should be populated with reporter's name" do
    visit new_investigation_correspondence_url(@investigation_with_reporter)
    assert_equal(@reporter.name, find_field('correspondence[correspondent_name]').value)
  end

  test "first step should be populated with reporter's email address" do
    visit new_investigation_correspondence_url(@investigation_with_reporter)
    assert_equal(@reporter.email_address, find_field('correspondence[email_address]').value)
  end

  test "second step should be correspondence details" do
    click_button "Continue"
    assert_text("Email body, transcript or notes")
  end

  test "third step should be confirmation" do
    click_button "Continue"
    click_button "Continue"
    assert_text("Correspondent")
    assert_text("Method")
  end

  test "confirmation edit details should go to first page in flow" do
    click_button "Continue"
    click_button "Continue"
    click_on "Edit details"
    assert_text("Who is the correspondence with?")
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
    visit new_investigation_correspondence_url(investigations(:no_products))
    click_button "Continue"
    click_button "Continue"
    click_button "Continue"
    assert_current_path(/cases\/\d+/)
  end

  test "case page should populate with correspondence details" do
    fill_in("correspondence[correspondent_name]", with: "Harry Potter")
    click_button "Continue"
    click_button "Continue"
    click_button "Continue"
    click_on "Full detail"
    assert_text("Harry Potter")
  end

  test "should allow to attach file" do
    click_button "Continue"
    attach_file("correspondence[file][file]", Rails.root + "test/fixtures/files/testImage.png")
    click_button "Continue"
    assert_text("testImage")
    click_button "Continue"
    click_on "Full detail"
    assert_text("testImage")
  end
end
