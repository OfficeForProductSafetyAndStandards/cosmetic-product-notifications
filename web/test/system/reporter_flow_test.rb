require "application_system_test_case"

class ReporterFlowTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin
    visit root_path
    click_on "Report an unsafe product"
  end

  teardown do
    logout
  end

  test "first step should be type" do
    assert_text("Reporter type")
  end

  test "type should be invalid if empty" do
    click_button "Continue"
    assert_text("Reporter type")
    assert_text("prohibited this case from being saved")
  end

  test "type should be valid if an option is selected" do
    select_type_and_continue
    assert_no_text("prohibited this case from being saved")
  end

  test "second step should be details" do
    select_type_and_continue
    assert_text("Reporter details")
  end

  test "name in details should not be empty" do
    select_type_and_continue
    click_button "Continue"
    assert_text("Reporter details")
    assert_text("prohibited this case from being saved")
  end

  test "details should be valid if name is not empty" do
    select_type_and_continue
    fill_name_and_continue
    assert_no_text("prohibited this case from being saved")
  end

  test "after submitting should go to recently created investigation page" do
    select_type_and_continue
    fill_name_and_continue
    assert_text("Case ID: ")
  end

  def select_type_and_continue
    choose("reporter[reporter_type]", visible: false, match: :first)
    click_button "Continue"
  end

  def fill_name_and_continue
    fill_in("reporter[name]", with: "Ben")
    click_button "Continue"
  end
end
