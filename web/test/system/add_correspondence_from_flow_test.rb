require "application_system_test_case"

class AddCorrespondenceFromFlowTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin
    @investigation = investigations(:one)
    visit new_investigation_correspondence_url(@investigation)
  end

  teardown do
    logout
  end

  test "first step should be type" do
    assert_text("Who is the correspondance with?")
  end

  test "first step should be populated with reporter name from the flow" do
    visit root_path
    click_on "Report an unsafe product"
    select_type_and_continue
    fill_name_and_continue
    click_on "Add reporter correspondance"
    assert_equal('Ben', find_field('correspondence[correspondent_name]').value)
  end

  test "first step should be populated with email from the flow" do
    visit root_path
    click_on "Report an unsafe product"
    select_type_and_continue
    fill_email_and_continue
    click_on "Add reporter correspondance"
    assert_equal('aa@aa.aa', find_field('correspondence[email_address]').value)
  end

  test "first step should be populated with phone from the flow" do
    visit root_path
    click_on "Report an unsafe product"
    select_type_and_continue
    fill_phone_and_continue
    click_on "Add reporter correspondance"
    assert_equal('12345678900', find_field('correspondence[phone_number]').value)
  end

  test "second step should be correspondence details" do
    click_button "Continue"
    assert_text("Email body, transcript or notes")
  end

  test "third step should be confirmation" do
    click_button "Continue"
    click_button "Continue"
    assert_text("Correspondant")
    assert_text("Method")
  end

  test "confirmation edit details should go to first page in flow" do
    click_button "Continue"
    click_button "Continue"
    click_on "Edit details"
    assert_text("Who is the correspondance with?")
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
    click_button "Continue"
    click_button "Continue"
    click_button "Continue"
    assert_text("There are no products attached to this case")
  end

  test "case page should populate with correspondence details" do
    fill_in("correspondence[correspondent_name]", with: "Harry Potter")
    click_button "Continue"
    click_button "Continue"
    click_button "Continue"
    click_on "Full detail"
    assert_text("Harry Potter")
  end

  def select_type_and_continue
    choose("reporter[reporter_type]", visible: false, match: :first)
    click_button "Continue"
  end

  def fill_name_and_continue
    fill_in("reporter[name]", with: "Ben")
    click_button "Continue"
  end

  def fill_email_and_continue
    fill_in("reporter[email_address]", with: "aa@aa.aa")
    click_button "Continue"
  end

  def fill_phone_and_continue
    fill_in("reporter[phone_number]", with: "12345678900")
    click_button "Continue"
  end
end
