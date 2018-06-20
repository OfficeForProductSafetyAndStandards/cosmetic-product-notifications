require "test_helper"

class InvestigationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:one)
    @investigation = investigations(:one)
  end

  test "should get index" do
    get investigations_url
    assert_response :success
  end

  test "should get new" do
    get new_investigation_url
    assert_response :success
  end

  test "should create investigation" do
    assert_difference("Investigation.count") do
      post investigations_url, params: {
        investigation: {
          description: @investigation.description,
          is_closed: @investigation.is_closed,
          product_id: @investigation.product_id,
          severity: @investigation.severity,
          source: @investigation.source
        }
      }
    end

    assert_redirected_to investigation_url(Investigation.first)
  end

  test "should show investigation" do
    get investigation_url(@investigation)
    assert_response :success
  end

  test "should get edit" do
    get edit_investigation_url(@investigation)
    assert_response :success
  end

  test "should update investigation" do
    patch investigation_url(@investigation), params: {
      investigation: {
        description: @investigation.description,
        is_closed: @investigation.is_closed,
        product_id: @investigation.product_id,
        severity: @investigation.severity,
        source: @investigation.source
      }
    }
    assert_redirected_to investigation_url(@investigation)
  end

  test "should destroy investigation" do
    assert_difference("Investigation.count", -1) do
      delete investigation_url(@investigation)
    end

    assert_redirected_to investigations_url
  end
end
