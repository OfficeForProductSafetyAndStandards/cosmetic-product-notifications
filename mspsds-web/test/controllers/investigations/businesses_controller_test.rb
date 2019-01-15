require "test_helper"

class Investigations::BusinessesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as_admin_with_organisation
    @investigation = investigations(:one)
    @business = businesses(:one)
    @business.source = sources(:business_one)
    Business.import refresh: true
    allow(CompaniesHouseClient.instance).to receive(:companies_house_businesses).and_return([])
  end

  teardown do
    logout
    allow(CompaniesHouseClient.instance).to receive(:companies_house_businesses).and_call_original
  end

  test "should get new" do
    get new_investigation_business_url(@investigation)
    assert_response :success
  end

  test "should create and link business" do
    assert_difference ["InvestigationBusiness.count", "Business.count"] do
      post investigation_businesses_url(@investigation), params: {
        business: {
          legal_name: @business.legal_name,
          trading_name: @business.trading_name,
          additional_information: @business.additional_information,
          company_number: @business.company_number,
          company_type_code: @business.company_type_code,
          company_status_code: @business.company_status_code,
          nature_of_business_id: @business.nature_of_business_id
        }
      }
    end
    assert_redirected_to investigation_path(@investigation, anchor: "businesses")
  end

  test "should not create business if name is missing" do
    assert_no_difference ["InvestigationBusiness.count", "Business.count"] do
      post investigation_businesses_url(@investigation), params: {
        business: {
          legal_name: '',
          additional_information: @business.additional_information,
          company_number: @business.company_number,
          company_type_code: @business.company_type_code,
          nature_of_business_id: @business.nature_of_business_id
        }
      }
    end
  end

  test "should link business and investigation" do
    assert_difference "InvestigationBusiness.count" do
      put link_investigation_business_url(@investigation, @business)
    end
    assert_redirected_to investigation_path(@investigation, anchor: "businesses")
  end

  test "should unlink business and investigation" do
    @investigation.businesses << @business
    assert_difference "InvestigationBusiness.count", -1 do
      delete unlink_investigation_business_url(@investigation, @business)
    end

    assert_redirected_to investigation_path(@investigation, anchor: "businesses")
  end
end
