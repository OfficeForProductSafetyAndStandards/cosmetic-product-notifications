require 'test_helper'

class CorrectiveActionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @corrective_action = corrective_actions(:one)
  end

  test "should get index" do
    get corrective_actions_url
    assert_response :success
  end

  test "should get new" do
    get new_corrective_action_url
    assert_response :success
  end

  test "should create corrective_action" do
    assert_difference('CorrectiveAction.count') do
      post corrective_actions_url, params: { corrective_action: { business_id: @corrective_action.business_id, date_decided: @corrective_action.date_decided, details: @corrective_action.details, investigation_id: @corrective_action.investigation_id, legislation: @corrective_action.legislation, product_id: @corrective_action.product_id, summary: @corrective_action.summary } }
    end

    assert_redirected_to corrective_action_url(CorrectiveAction.last)
  end

  test "should show corrective_action" do
    get corrective_action_url(@corrective_action)
    assert_response :success
  end

  test "should get edit" do
    get edit_corrective_action_url(@corrective_action)
    assert_response :success
  end

  test "should update corrective_action" do
    patch corrective_action_url(@corrective_action), params: { corrective_action: { business_id: @corrective_action.business_id, date_decided: @corrective_action.date_decided, details: @corrective_action.details, investigation_id: @corrective_action.investigation_id, legislation: @corrective_action.legislation, product_id: @corrective_action.product_id, summary: @corrective_action.summary } }
    assert_redirected_to corrective_action_url(@corrective_action)
  end

  test "should destroy corrective_action" do
    assert_difference('CorrectiveAction.count', -1) do
      delete corrective_action_url(@corrective_action)
    end

    assert_redirected_to corrective_actions_url
  end
end
