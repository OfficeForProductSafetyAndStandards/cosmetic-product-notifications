require "test_helper"

class BusinessTest < ActiveSupport::TestCase
  test "Business requires a company name" do
    business = Business.new
    assert_not business.save
    business.company_name = 'Test'
    assert business.save
  end

  test "populates data correctly from companies house info" do
    # Arrange
    # Entity shape definition at
    # https://developer.companieshouse.gov.uk/api/docs/company/company_number/companyProfile-resource.html
    response = {
        "company_number" => "234",
        "company_name" => "Turbo Frogs",
        "type" => "ltd",
        "company_status" => "active",
        "sic_codes" => ["SIC code"],
        "registered_office_address" => {
            "address_line_1" => "Sesame Street",
            "address_line_2" => "123",
            "locality" => "New York City",
            "country" => "USA",
            "postal_code" => "55555",
        }
    }

    # Act
    business = Business.from_companies_house_response(response)

    # Assert
    assert_equal(business.company_number, "234")
    assert_equal(business.company_name, "Turbo Frogs")
    assert_equal(business.company_type_code, "ltd")
    assert_equal(business.company_status_code, "active")
    assert_equal(business.source.show, "Companies House")
    assert_equal(business.nature_of_business_id, "SIC code")
    address = business.primary_address
    assert_equal(address.address_type, "Registered office address")
    assert_equal(address.line_1, "Sesame Street")
    assert_equal(address.line_2, "123")
    assert_equal(address.locality, "New York City")
    assert_equal(address.country, "USA")
    assert_equal(address.postal_code, "55555")
    assert_equal(address.source.show, "Companies House")
  end
end
