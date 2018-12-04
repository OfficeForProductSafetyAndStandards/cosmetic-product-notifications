require "application_system_test_case"

class ReporterFlowTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin
    visit new_report_path
  end

  teardown do
    logout
  end

  test "first step should be reporter type" do
    assert_text "Who's reporting?"
  end

  test "should be able to select an option" do
    select_type_and_continue
    assert_no_text "prevented this reporter from being saved"
  end

  test "second step should be reporter details" do
    select_type_and_continue
    assert_text "What are their contact details?"
  end

  test "should be able to fill name" do
    select_type_and_continue
    fill_name_and_continue
    assert_no_text "prevented this reporter from being saved"
  end

  test "last step should be confirmation" do
    select_type_and_continue
    fill_name_and_continue
    assert_text "Case created\nYour reference number"
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
