require "test_helper"

class InvestigationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in_as_admin
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

  test "should close investigation" do
    post close_investigation_path(@investigation)

    investigation = Investigation.find(@investigation.id)
    assert_redirected_to investigation_url(investigation)
    assert investigation.is_closed?
  end

  test "should reopen investigation" do
    @investigation.is_closed = true
    @investigation.save!

    post reopen_investigation_path(@investigation)

    investigation = Investigation.find(@investigation.id)
    assert_redirected_to investigation_url(investigation)
    assert_not investigation.is_closed?
  end

  test "should disallow non-admins from reopening investigation" do
    @investigation.is_closed = true
    @investigation.save!
    sign_in_as_user

    assert_raise Pundit::NotAuthorizedError do
      post reopen_investigation_path(@investigation)
    end

    investigation = Investigation.find(@investigation.id)
    assert investigation.is_closed?
  end

  private

  def sign_in_as_admin
    user = users(:one)
    user.add_role(:user)
    user.add_role(:admin)
    sign_in user
  end

  def sign_in_as_user
    user = users(:two)
    user.add_role(:user)
    sign_in user
  end
end
