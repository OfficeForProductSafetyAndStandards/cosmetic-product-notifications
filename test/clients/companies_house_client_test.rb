require "companies_house/client"
require "test_helper"
require "rspec/mocks/standalone"

class CompaniesHouseClientTest < ActiveSupport::TestCase
  include ::RSpec::Mocks::ExampleMethods

  setup do
    client_instance = instance_double("CompaniesHouse::Client")
    allow(CompaniesHouse::Client).to receive(:new).and_return(client_instance)
    allow(client_instance).to receive(:company_search).with("xyz").and_return("items" => [
      {
        "title" => "company XYZ",
        "company_number" => "123",
        "company_status" => "active",
      }
    ])
  end

  teardown do
    allow(CompaniesHouse::Client).to receive(:new).and_call_original
  end

  test "companies_house_businesses returns parsed data" do
    results = CompaniesHouseClient.instance.companies_house_businesses("xyz")
    assert_equal(results, [
      {
        company_name: "company XYZ",
        company_number: "123",
        company_status_code: "active",
        url: "https://beta.companieshouse.gov.uk/company/123"
      }
    ])
  end
end
