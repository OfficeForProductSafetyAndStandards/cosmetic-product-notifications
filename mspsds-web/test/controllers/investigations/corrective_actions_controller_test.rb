require 'test_helper'

class CorrectiveActionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @investigation = investigations(:one)
    @business = businesses(:one)
    @product = products(:one)
    sign_in_as_opss_user
  end

  teardown do
    logout
  end

  test "should redirect new corrective action request to first wizard step" do
    get new_investigation_corrective_action_path(@investigation)
    assert_redirected_to investigation_corrective_actions_path(@investigation) + '/details'
  end

  test "should create corrective action" do
    assert_difference("CorrectiveAction.count") do
      post investigation_corrective_actions_path(@investigation), params: {
        corrective_action: {
          product_id: @product.id,
          business_id: @business.id,
          legislation: "Test Legislation",
          summary: "Test Summary",
          details: "Test Details",
          year: "2018",
          month: "11",
          day: "18"
        }
      }
    end

    assert_redirected_to investigation_url(@investigation)
  end

  test "should add corrective action to investigation" do
    post investigation_corrective_actions_path(@investigation), params: {
      corrective_action: {
        product_id: @product.id,
        business_id: @business.id,
        legislation: "Test Legislation",
        summary: "Test Summary",
        details: "Test Details",
        year: "2018",
        month: "11",
        day: "18"
      }
    }

    assert_equal(Investigation.first.corrective_actions.last.legislation, "Test Legislation")
  end
end
