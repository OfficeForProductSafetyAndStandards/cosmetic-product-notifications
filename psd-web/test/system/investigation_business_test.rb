require "application_system_test_case"

class InvestigationBusinessTest < ApplicationSystemTestCase
  setup do
    mock_out_keycloak_and_notify
    @investigation = load_case(:one)
    @business = businesses(:three)
    @business.source = sources(:business_three)
    @location = locations(:one)
    @contact = contacts(:one)
    visit new_investigation_business_path(@investigation)
  end

  teardown do
    reset_keycloak_and_notify_mocks
  end

  test "create a business on investigation" do
    select_business_type
    click_on "Continue"
    fill_in_business_details
    click_on "Save business"
    click_on "Businesses"
    assert_text @business.trading_name
  end

  test "should not create business if name is missing" do
    select_business_type
    click_on "Continue"
    fill_in "business[legal_name]", with: @business.legal_name
    fill_in "business[trading_name]", with: ''
    fill_in "business[company_number]", with: @business.company_number
    click_on "Save business"
    assert_text "Trading name can't be blank"
  end

  test "cannot allow business type to be empty" do
    click_on "Continue"
    assert_text "Please select a business type"
  end

  test "cannot allow business type other to be empty" do
    choose "business_type_other", visible: false
    click_on "Continue"
    assert_text 'Please enter a business type "Other"'
  end

  test "should unlink business" do
    visit remove_investigation_business_path(@investigation, @business)
    assert_text @business.trading_name
    click_on "Remove business"
    assert_no_text @business.trading_name
  end

  def select_business_type
    choose "business_type_importer", visible: false
  end

  def select_business_type_other
    choose "business_type_other", visible: false
    fill_in "business[type_other]", with: "Other"
  end

  def fill_in_business_details
    fill_in "business[legal_name]", with: @business.legal_name
    fill_in "business[trading_name]", with: @business.trading_name
    fill_in "business[company_number]", with: @business.company_number
    fill_in "business_locations_attributes_0_address_line_1", with: @location.address_line_1
    fill_in "business_locations_attributes_0_postal_code", with: @location.postal_code
    fill_in "business_contacts_attributes_0_name", with: @contact.name
  end
end
