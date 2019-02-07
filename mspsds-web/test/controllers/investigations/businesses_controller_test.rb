require "test_helper"

class Investigations::BusinessesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as_admin
    @investigation = investigations(:one)
    @business = businesses(:three)
    @business.source = sources(:business_three)
    Business.import refresh: true
  end

  teardown do
    logout
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
          company_number: "new company number",
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
          company_number: "new company number",
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
    @investigation.add_business @business, "manufacturer"
    assert_difference "InvestigationBusiness.count", -1 do
      delete unlink_investigation_business_url(@investigation, @business)
    end

    assert_redirected_to investigation_path(@investigation, anchor: "businesses")
  end
end
