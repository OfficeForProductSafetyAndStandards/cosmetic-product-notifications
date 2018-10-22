require 'test_helper'

class HazardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as_admin
  end

  teardown do
    logout
  end
  
  setup do
    @hazard = hazards(:one)
    @investigation = Investigation.new
    @investigation.save
  end

  test "should get new" do
    get new_investigation_hazard_url(@investigation)
    assert_response :success
  end

  test "should create hazard" do
    assert_difference('Hazard.count') do
      post investigation_hazards_url(@investigation), params: { hazard: { affected_parties: @hazard.affected_parties, description: @hazard.description, hazard_type: @hazard.hazard_type, investigation: @hazard.investigation, risk_level: @hazard.risk_level } }
    end

    assert_redirected_to investigation_url(@investigation)
  end

  test "should show hazard" do
    get investigation_hazard_url(@investigation, @hazard)
    assert_response :success
  end

  test "should get edit" do
    get edit_investigation_hazard_url(@investigation, @hazard)
    assert_response :success
  end

  test "should update hazard" do
    patch investigation_hazard_url(@investigation, @hazard), params: { hazard: { affected_parties: @hazard.affected_parties, description: @hazard.description, hazard_type: @hazard.hazard_type, investigation: @hazard.investigation, risk_level: @hazard.risk_level } }
    assert_redirected_to investigation_hazard_url(@investigation, @hazard)
  end

  test "should destroy hazard" do
    assert_difference('Hazard.count', -1) do
      delete investigation_hazard_url(@investigation, @hazard)
    end

    assert_redirected_to investigation_hazards_url(@investigation)
  end
end
