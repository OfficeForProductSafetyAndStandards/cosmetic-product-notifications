require "test_helper"

class InvestigationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as_admin
    @investigation = investigations(:one)
    @investigation.source = sources(:investigation_one)
    @investigation.hazard = hazards(:one)
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
    new_investigation_description = "new_investigation_description"
    assert_difference("Investigation.count") do
      post investigations_url, params: {
        investigation: {
            description: new_investigation_description
        }
      }
    end

    new_investigation = Investigation.find_by(description: new_investigation_description)
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

  test "redirect to investigation path if attempted to assign a person to closed investigation" do
    investigation = investigations(:three)
    get assign_investigation_url(investigation)
    assert_redirected_to investigation_path(investigation)
  end

  test "should assign user to investigation" do
    id = User.first.id
    investigation_assignee_id = lambda { Investigation.find(@investigation.id).assignee_id }
    assert_changes investigation_assignee_id, from: nil, to: id do
      post update_assignee_investigation_url @investigation, params: {
        assignee_id: id
      }
    end
    assert_redirected_to investigation_url(@investigation)
  end
end
