require "application_system_test_case"

class BusinessesTest < ApplicationSystemTestCase
  setup do
    @business = businesses(:one)
  end

  test "visiting the index" do
    visit businesses_url
    assert_selector "h1", text: "Businesses"
  end

  test "creating a Business" do
    visit businesses_url
    click_on "New Business"

    fill_in "Additional Information", with: @business.additional_information
    fill_in "Company Name", with: @business.company_name
    fill_in "Company Number", with: @business.company_number
    fill_in "Company Type", with: @business.company_type_code
    fill_in "Nature Of Business", with: @business.nature_of_business_id
    fill_in "Registered Office Address Country", with: @business.registered_office_address_country
    fill_in "Registered Office Address Line 1", with: @business.registered_office_address_line_1
    fill_in "Registered Office Address Line 2", with: @business.registered_office_address_line_2
    fill_in "Registered Office Address Locality", with: @business.registered_office_address_locality
    fill_in "Registered Office Address Postal Code", with: @business.registered_office_address_postal_code
    click_on "Create Business"

    assert_text "Business was successfully created"
    click_on "Back"
  end

  test "updating a Business" do
    visit businesses_url
    click_on "Edit", match: :first

    fill_in "Additional Information", with: @business.additional_information
    fill_in "Company Name", with: @business.company_name
    fill_in "Company Number", with: @business.company_number
    fill_in "Company Type", with: @business.company_type_code
    fill_in "Nature Of Business", with: @business.nature_of_business_id
    fill_in "Registered Office Address Country", with: @business.registered_office_address_country
    fill_in "Registered Office Address Line 1", with: @business.registered_office_address_line_1
    fill_in "Registered Office Address Line 2", with: @business.registered_office_address_line_2
    fill_in "Registered Office Address Locality", with: @business.registered_office_address_locality
    fill_in "Registered Office Address Postal Code", with: @business.registered_office_address_postal_code
    click_on "Update Business"

    assert_text "Business was successfully updated"
    click_on "Back"
  end

  test "destroying a Business" do
    visit businesses_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Business was successfully destroyed"
  end
end
