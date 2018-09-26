require "test_helper"
require "rspec/mocks/standalone"

class BusinessHelperTest < ActiveSupport::TestCase
  include ::RSpec::Mocks::ExampleMethods
  include BusinessesHelper

  setup do
    client_instance = instance_double("CompaniesHouseClient")
    allow(CompaniesHouseClient).to receive(:instance).and_return(client_instance)
    allow(client_instance).to receive(:companies_house_businesses).with("company").and_return(
      [
        {
          company_name: "company one, already in the db",
          company_number: "1",
          company_status_code: "active",
          url: "urlToView/1"
        },
        {
          company_name: "company two",
          company_number: "2",
          company_status_code: "dissolved",
          url: "urlToView/2"
        },
        {
          company_name: "company three",
          company_number: "3",
          company_status_code: "active",
          url: "urlToView/3"
        },
        {
          company_name: "company four",
          company_number: "4",
          company_status_code: "active",
          url: "urlToView/4"
        },
      ]
    )
  end

  teardown do
    allow(CompaniesHouseClient).to receive(:instance).and_call_original
  end

  test "search_companies_house returns only new companies" do
    results = search_companies_house("company")
    assert_equal(results.map { |company| company[:company_number] }, %w(2 3 4))
  end
end
