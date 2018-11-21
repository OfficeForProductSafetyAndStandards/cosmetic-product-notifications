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

  test "should be able to select option" do
    select_type_and_continue
    assert_no_text("prohibited this item from being saved")
  end

  test "second step should be details" do
    select_type_and_continue
    assert_text("Reporter details")
  end

  test "should be able to fill name" do
    select_type_and_continue
    fill_name_and_continue
    assert_no_text("prohibited this item from being saved")
  end

  test "last step should be confirmation" do
    select_type_and_continue
    fill_name_and_continue
    assert_text("Case created\nYour reference number")
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
