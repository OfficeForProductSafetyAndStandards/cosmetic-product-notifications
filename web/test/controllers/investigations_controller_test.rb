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

  test "should assign user to investigation" do
    id = User.first.id
    investigation_assignee_id = lambda { Investigation.find(@investigation.id).assignee_id }
    assert_changes investigation_assignee_id, from: nil, to: id do
      put investigation_url(@investigation), params: {
        investigation: {
          assignee_id: id
        }
      }
    end
    assert_redirected_to investigation_url(@investigation)
  end

  test "should set priority" do
    priority = "high"
    investigation_priority = lambda { Investigation.find(@investigation.id).priority }
    assert_changes investigation_priority, from: nil, to: priority do
      put investigation_url(@investigation), params: {
        investigation: {
          priority: priority,
          priority_rationale: "some rationale"
        }
      }
    end
    assert_redirected_to investigation_url(@investigation)
  end

  test "should not save priority_rationale if priority is nil" do
    investigation = investigations(:two)
    investigation.source = sources(:investigation_two)
    investigation_priority = lambda { Investigation.find(investigation.id).priority }
    assert_no_changes investigation_priority do
      put investigation_url(@investigation), params: {
        investigation: {
          priority: nil,
          priority_rationale: "some rational"
        }
      }
    end
  end

  test "should set status" do
    is_closed = true
    investigation_status = lambda { Investigation.find(@investigation.id).is_closed }
    assert_changes investigation_status, from: false, to: is_closed do
      put investigation_url(@investigation), params: {
          investigation: {
              is_closed: is_closed,
              status_rationale: "some rationale"
          }
      }
    end
    assert_redirected_to investigation_url(@investigation)
  end

  test "should update assignee from selectable list" do
    assignee = User.first
    put investigation_url(@investigation), params: {
      investigation: {
        assignee_id: assignee.id
      }
    }
    assert_equal(Investigation.find(@investigation.id).assignee.id, assignee.id)
  end

  test "should update assignee from radio boxes" do
    assignee = User.first
    put investigation_url(@investigation), params: {
      investigation: {
        assignee_id_radio: assignee.id
      }
    }
    assert_equal(Investigation.find(@investigation.id).assignee.id, assignee.id)
  end
end
