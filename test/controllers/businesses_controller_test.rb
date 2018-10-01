require "test_helper"

class BusinessesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as_admin
    @business = businesses(:one)
    @business.source = sources(:business_one)
    Business.import
    allow(CompaniesHouseClient.instance).to receive(:companies_house_businesses).and_return([])
  end

  teardown do
    logout
    allow(CompaniesHouseClient.instance).to receive(:companies_house_businesses).and_call_original
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
          company_name: @business.company_name,
          additional_information: @business.additional_information,
          company_number: @business.company_number,
          company_type_code: @business.company_type_code,
          company_status_code: @business.company_status_code,
          nature_of_business_id: @business.nature_of_business_id
        }
      }
    end
    assert_redirected_to business_url(Business.first)
  end

  test "should not create business if name is missing" do
    assert_difference("Business.count", 0) do
      post businesses_url, params: {
        business: {
          company_name: '',
          additional_information: @business.additional_information,
          company_number: @business.company_number,
          company_type_code: @business.company_type_code,
          nature_of_business_id: @business.nature_of_business_id
        }
      }
    end
  end

  test "should show business" do
    get business_url(@business)
    assert_response :success
  end

  test "should get edit" do
    get edit_business_url(@business)
    assert_response :success
  end

  test "should update business" do
    patch business_url(@business), params: {
      business: {
        company_name: @business.company_name,
        additional_information: @business.additional_information,
        company_number: @business.company_number,
        company_type_code: @business.company_type_code,
        company_status_code: @business.company_status_code,
        nature_of_business_id: @business.nature_of_business_id
      }
    }
    assert_redirected_to business_url(@business)
  end

  test "should destroy business" do
    assert_difference("Business.count", -1) do
      delete business_url(@business)
    end

    assert_redirected_to businesses_url
  end

  test "should search for similar businesses" do
    get search_businesses_url, params: { company_name: "Biscuit", company_type_code: "private-unlimited" }
    assert_response :success
  end
end
