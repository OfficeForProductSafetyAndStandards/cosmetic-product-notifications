require "test_helper"
require "rspec/mocks/standalone"

class BusinessHelperTest < ActiveSupport::TestCase
  include ::RSpec::Mocks::ExampleMethods
  include BusinessesHelper

  setup do
    Business.import force: true, refresh: true
  end

  teardown do
  end

  test "local search respects company type" do
    # Act
    search_model_ltd = Business.new(legal_name: "biscuit", company_type_code: "ltd")
    results_ltd = search_for_similar_businesses(search_model_ltd, [])
    search_model_pu = Business.new(legal_name: "biscuit", company_type_code: "private-unlimited")
    results_pu = search_for_similar_businesses(search_model_pu, [])

    # Assert
    assert_includes(results_pu.map(&:legal_name), "Biscuit Base")
    assert_not_includes(results_ltd.map(&:legal_name), "Biscuit Base")
  end

  test "local search respects company status" do
    # Act
    search_model_active = Business.new(legal_name: "biscuit", company_status_code: "active")
    results_active = search_for_similar_businesses(search_model_active, [])
    search_model_dissolved = Business.new(legal_name: "biscuit", company_status_code: "dissolved")
    results_dissolved = search_for_similar_businesses(search_model_dissolved, [])

    # Assert
    assert_includes(results_active.map(&:legal_name), "Biscuit Base")
    assert_not_includes(results_dissolved.map(&:legal_name), "Biscuit Base")
  end
end
