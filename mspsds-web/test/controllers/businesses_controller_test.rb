require "test_helper"

class BusinessesControllerTest < ActionDispatch::IntegrationTest
  setup do
    mock_out_keycloak_and_notify
    accept_declaration
    @business_one = businesses(:one)
    @business_two = businesses(:two)
    @business_one.source = sources(:business_one)
    @business_two.source = sources(:business_two)
    Business.import refresh: true
  end

  teardown do
    reset_keycloak_and_notify_mocks
  end

  test "should get index" do
    get businesses_url
    assert_response :success
  end

  test "should show business" do
    get business_url(@business_one)
    assert_response :success
  end

  test "should get edit" do
    get edit_business_url(@business_one)
    assert_response :success
  end

  test "should update business" do
    patch business_url(@business_one), params: {
      business: {
        legal_name: "new legal_name for business_one",
        trading_name: "new trading_name for business_one",
        company_number: "new company number for business_one"
      }
    }
    assert_redirected_to business_url(@business_one)
  end
end
