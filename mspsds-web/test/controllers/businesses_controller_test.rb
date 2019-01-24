require "test_helper"

class BusinessesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as_admin
    @business_one = businesses(:one)
    @business_two = businesses(:two)
    @business_one.source = sources(:business_one)
    @business_two.source = sources(:business_two)
    Business.import refresh: true
  end

  teardown do
    logout
  end

  test "should get index" do
    get businesses_url
    assert_response :success
  end

  test "should get new" do
    get new_business_url
    assert_response :success
  end

  test "should create business" do
    assert_difference("Business.count") do
      post businesses_url, params: {
        business: {
          legal_name: @business_two.legal_name,
          trading_name: @business_two.trading_name,
          company_number: "new_company_number"
        }
      }
    end
    assert_redirected_to business_url(Business.last)
  end

  test "should not create business if name is missing" do
    assert_difference("Business.count", 0) do
      post businesses_url, params: {
        business: {
          legal_name: '',
          company_number: "new_company_number"
        }
      }
    end
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

  test "should destroy business" do
    assert_difference("Business.count", -1) do
      delete business_url(@business_one)
    end

    assert_redirected_to businesses_url
  end
end
