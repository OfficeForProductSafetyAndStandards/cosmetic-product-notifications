require 'test_helper'

class HazardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @hazard = hazards(:one)
  end

  test "should get index" do
    get hazards_url
    assert_response :success
  end

  test "should get new" do
    get new_hazard_url
    assert_response :success
  end

  test "should create hazard" do
    assert_difference('Hazard.count') do
      post hazards_url, params: { hazard: { affected_parties: @hazard.affected_parties, description: @hazard.description, hazard_type: @hazard.hazard_type, investigation: @hazard.investigation, risk_level: @hazard.risk_level } }
    end

    assert_redirected_to hazard_url(Hazard.last)
  end

  test "should show hazard" do
    get hazard_url(@hazard)
    assert_response :success
  end

  test "should get edit" do
    get edit_hazard_url(@hazard)
    assert_response :success
  end

  test "should update hazard" do
    patch hazard_url(@hazard), params: { hazard: { affected_parties: @hazard.affected_parties, description: @hazard.description, hazard_type: @hazard.hazard_type, investigation: @hazard.investigation, risk_level: @hazard.risk_level } }
    assert_redirected_to hazard_url(@hazard)
  end

  test "should destroy hazard" do
    assert_difference('Hazard.count', -1) do
      delete hazard_url(@hazard)
    end

    assert_redirected_to hazards_url
  end
end
