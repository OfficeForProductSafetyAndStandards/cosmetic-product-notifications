require "companies_house/client"
require "test_helper"
require "rspec/mocks/standalone"

class CompaniesHouseClientTest < ActiveSupport::TestCase
  include ::RSpec::Mocks::ExampleMethods

  setup do
    client_mock = instance_double("CompaniesHouse::Client", company_search: { "items" => [
      {
        "title" => "company XYZ",
        "company_number" => "123",
        "company_status" => "active",
        "company_type" => "ltd",
      }
    ] })
    # temporarily stubbing the constructor of Client ...
    allow(CompaniesHouse::Client).to receive(:new).and_return(client_mock)
    # ... to be used by the CompaniesHouseClient singleton initialization (specific to this spec)
    @companies_house_client = Class.new(CompaniesHouseClient).instance
    allow(CompaniesHouse::Client).to receive(:new).and_call_original
  end

  test "companies_house_businesses returns parsed data" do
    results = @companies_house_client.companies_house_businesses("xyz")
    assert_equal(results, [
      {
        company_name: "company XYZ",
        company_number: "123",
        company_status_code: "active",
        company_type_code: "ltd",
        url: "https://beta.companieshouse.gov.uk/company/123"
      }
    ])
  end
end
