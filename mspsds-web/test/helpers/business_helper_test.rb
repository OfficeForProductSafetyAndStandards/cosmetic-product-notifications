require "test_helper"
require "rspec/mocks/standalone"

class BusinessHelperTest < ActiveSupport::TestCase
  include ::RSpec::Mocks::ExampleMethods
  include BusinessesHelper

  setup do
    Business.import force: true, refresh: true
    @client_instance = instance_double("CompaniesHouseClient")
    allow(CompaniesHouseClient).to receive(:instance).and_return(@client_instance)
    allow(@client_instance).to receive(:companies_house_businesses).with("company").and_return(
      [
        {
          company_name: "company one, already in the db",
          company_number: "1",
          company_type_code: "private-unlimited",
          company_status_code: "active",
          url: "urlToView/1"
        },
        {
          company_name: "company two",
          company_number: "2",
          company_type_code: "private-unlimited",
          company_status_code: "dissolved",
          url: "urlToView/2"
        },
        {
          company_name: "company three",
          company_number: "3",
          company_type_code: "ltd",
          company_status_code: "active",
          url: "urlToView/3"
        },
        {
          company_name: "company four",
          company_number: "4",
          company_type_code: "ltd",
          company_status_code: "liquidation",
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
    assert_equal(%w(2 3 4), results.map { |company| company[:company_number] })
  end

  test "companies house search respects company type" do
    # Act
    search_model = Business.new(company_name: "company", company_type_code: "ltd")
    results = search_companies_house_for_similar_businesses(search_model)
                .map { |b| b[:company_name] }

    # Assert
    assert_equal(["company three", "company four"], results)
  end

  test "companies house search respects company status" do
    # Act
    search_model = Business.new(company_name: "company", company_status_code: "liquidation")
    results = search_companies_house_for_similar_businesses(search_model)
                .map { |b| b[:company_name] }

    # Assert
    assert_equal(["company four"], results)
  end

  test "local search respects company type" do
    # Act
    search_model_ltd = Business.new(company_name: "biscuit", company_type_code: "ltd")
    results_ltd = search_for_similar_businesses(search_model_ltd, [])
    search_model_pu = Business.new(company_name: "biscuit", company_type_code: "private-unlimited")
    results_pu = search_for_similar_businesses(search_model_pu, [])

    # Assert
    assert_includes(results_pu.map(&:company_name), "Biscuit Base")
    assert_not_includes(results_ltd.map(&:company_name), "Biscuit Base")
  end

  test "local search respects company status" do
    # Act
    search_model_active = Business.new(company_name: "biscuit", company_status_code: "active")
    results_active = search_for_similar_businesses(search_model_active, [])
    search_model_dissolved = Business.new(company_name: "biscuit", company_status_code: "dissolved")
    results_dissolved = search_for_similar_businesses(search_model_dissolved, [])

    # Assert
    assert_includes(results_active.map(&:company_name), "Biscuit Base")
    assert_not_includes(results_dissolved.map(&:company_name), "Biscuit Base")
  end

  test "companies house outage doesn't affect local search" do
    # Assemble
    allow(@client_instance).to receive(:companies_house_businesses).with("Hello Kitty")
      .and_raise(CompaniesHouseClient::ClientException)

    # Act + Assert
    assert_nothing_raised do
      @business = Business.new company_name: "Hello Kitty"
      advanced_search
    end
    assert_not_nil(@existing_businesses.present?)
    assert_nil(@companies_house_businesses)
    assert_equal(true, @companies_house_error)
  end
end
