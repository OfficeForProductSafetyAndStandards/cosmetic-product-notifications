require "test_helper"

class InvestigationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as_admin
    @investigation = investigations(:one)
    @investigation.source = sources(:investigation_one)
    Investigation.import
  end

  teardown do
    logout
  end

  test "should get index" do
    get investigations_url
    assert_response :success
  end

  test "should get new" do
    get new_investigation_url
    assert_response :success
  end

  test "should create investigation and redirect to investigation page" do
    new_investigation_title = "new_investigation_title"
    assert_difference("Investigation.count") do
      post investigations_url, params: {
        investigation: {
          title: new_investigation_title,
        }
      }
    end

    new_investigation = Investigation.find_by(title: new_investigation_title)
    assert_redirected_to investigation_path(new_investigation)
  end

  test "should show investigation" do
    get investigation_url(@investigation)
    assert_response :success
  end

  test "should generate investigation pdf" do
    get investigation_url(@investigation, format: :pdf)
    assert_response :success
  end

  test "should get edit" do
    get edit_investigation_url(@investigation)
    assert_response :success
  end

  test "should update investigation" do
    patch investigation_url(@investigation), params: {
      investigation: {
        title: @investigation.title,
        description: @investigation.description,
        is_closed: @investigation.is_closed,
        source: @investigation.source,
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

  test "redirect to investigation path if attempted to assign a person to closed investigation" do
    investigation = investigations(:three)
    get assign_investigation_url(investigation)
    assert_redirected_to investigation_path(investigation)
  end

  test "should assign user to investigation" do
    id = "user_id"
    assert_changes(@investigation.assignee, to: id) do
      post update_assignee_investigation_url @investigation, params: {
        assignee_id: id
      }
    end
    assert_response :success
  end
end
