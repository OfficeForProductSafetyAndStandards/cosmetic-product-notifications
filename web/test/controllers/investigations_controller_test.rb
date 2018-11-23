require "test_helper"

class InvestigationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as_admin
    @investigation_one = investigations(:one)
    @investigation_two = investigations(:two)
    @investigation_three = investigations(:three)
    @investigation_no_products = investigations(:no_products)
    @investigation_one.source = sources(:investigation_one)
    @investigation_one.hazard = hazards(:one)

    @investigation_one.created_at = Time.zone.parse('2014-07-11 21:00')
    @investigation_one.updated_at = Time.zone.parse('2017-07-11 21:00')
    @investigation_one.save
    @investigation_two.created_at = Time.zone.parse('2015-07-11 21:00')
    @investigation_two.updated_at = Time.zone.parse('2016-07-11 21:00')
    @investigation_two.save
    Investigation.import force: true
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
    get investigation_url(@investigation_one)
    assert_response :success
  end

  test "should generate investigation pdf" do
    get investigation_url(@investigation_one, format: :pdf)
    assert_response :success
  end

  test "should assign user to investigation" do
    id = User.first.id
    investigation_assignee_id = lambda { Investigation.find(@investigation_one.id).assignee_id }
    assert_changes investigation_assignee_id, from: nil, to: id do
      put investigation_url(@investigation_one), params: {
        investigation: {
          assignee_id: id
        }
      }
    end
    assert_redirected_to investigation_url(@investigation_one)
  end

  test "should set priority" do
    priority = "high"
    investigation_priority = lambda { Investigation.find(@investigation_one.id).priority }
    assert_changes investigation_priority, from: nil, to: priority do
      put investigation_url(@investigation_one), params: {
        investigation: {
          priority: priority,
          priority_rationale: "some rationale"
        }
      }
    end
    assert_redirected_to investigation_url(@investigation_one)
  end

  test "should not save priority_rationale if priority is nil" do
    investigation = investigations(:two)
    investigation.source = sources(:investigation_two)
    investigation_priority = lambda { Investigation.find(investigation.id).priority }
    assert_no_changes investigation_priority do
      put investigation_url(@investigation_one), params: {
        investigation: {
          priority: nil,
          priority_rationale: "some rational"
        }
      }
    end
  end

  test "should set status" do
    is_closed = true
    investigation_status = lambda { Investigation.find(@investigation_one.id).is_closed }
    assert_changes investigation_status, from: false, to: is_closed do
      put investigation_url(@investigation_one), params: {
          investigation: {
              is_closed: is_closed,
              status_rationale: "some rationale"
          }
      }
    end
    assert_redirected_to investigation_url(@investigation_one)
  end

  test "should update assignee from selectable list" do
    assignee = User.first
    put investigation_url(@investigation_one), params: {
      investigation: {
        assignee_id: assignee.id
      }
    }
    assert_equal(Investigation.find(@investigation_one.id).assignee.id, assignee.id)
  end

  test "should update assignee from radio boxes" do
    assignee = User.first
    put investigation_url(@investigation_one), params: {
      investigation: {
        assignee_id_radio: assignee.id
      }
    }
    assert_equal(Investigation.find(@investigation_one.id).assignee.id, assignee.id)
  end

  test "status filter should be defaulted to open" do
    get investigations_path
    assert_not_includes(response.body, @investigation_three.pretty_id)
    assert_includes(response.body, @investigation_one.pretty_id)
    assert_includes(response.body, @investigation_two.pretty_id)
    assert_includes(response.body, @investigation_no_products.pretty_id)
  end

  test "status filter for both open and closed checked" do
    get investigations_path, params: {
      status_open: "checked",
      status_closed: "checked"
    }
    assert_includes(response.body, @investigation_three.pretty_id)
    assert_includes(response.body, @investigation_one.pretty_id)
    assert_includes(response.body, @investigation_two.pretty_id)
    assert_includes(response.body, @investigation_no_products.pretty_id)
  end

  test "status filter for both open and closed unchecked" do
    get investigations_path, params: {
      status_open: "unchecked",
      status_closed: "unchecked"
    }
    assert_includes(response.body, @investigation_three.pretty_id)
    assert_includes(response.body, @investigation_one.pretty_id)
    assert_includes(response.body, @investigation_two.pretty_id)
    assert_includes(response.body, @investigation_no_products.pretty_id)
  end

  test "status filter for only open checked" do
    get investigations_path, params: {
      status_open: "checked",
      status_closed: "unchecked"
    }
    assert_not_includes(response.body, @investigation_three.pretty_id)
    assert_includes(response.body, @investigation_one.pretty_id)
    assert_includes(response.body, @investigation_two.pretty_id)
    assert_includes(response.body, @investigation_no_products.pretty_id)
  end

  test "status filter for only closed checked" do
    get investigations_path, params: {
      status_open: "unchecked",
      status_closed: "checked"
    }
    assert_includes(response.body, @investigation_three.pretty_id)
    assert_not_includes(response.body, @investigation_one.pretty_id)
    assert_not_includes(response.body, @investigation_two.pretty_id)
    assert_not_includes(response.body, @investigation_no_products.pretty_id)
  end

  test "sort by filter should be defaulted to Updated: recent" do
    get investigations_path
    assert response.body.index(@investigation_one.id.to_s) < response.body.index(@investigation_two.id.to_s)
  end

  test "should return the most recently updated investigation first if sort by 'Updated: recent' is selected" do
    get investigations_path, params: {
        status_open: "unchecked",
        status_closed: "unchecked",
        sort_by: "recent"
    }
    assert response.body.index(@investigation_one.id.to_s) < response.body.index(@investigation_two.id.to_s)
  end

  test "should return the oldest updated investigation first if sort by 'Updated: oldest' is selected" do
    get investigations_path, params: {
        status_open: "unchecked",
        status_closed: "unchecked",
        sort_by: "oldest"
    }
    assert response.body.index(@investigation_two.id.to_s) < response.body.index(@investigation_one.id.to_s)
  end

  test "should return the most recently created investigation first if sort by 'Created: newest' is selected" do
    get investigations_path, params: {
        status_open: "unchecked",
        status_closed: "unchecked",
        sort_by: "newest"
    }
    assert response.body.index(@investigation_two.id.to_s) < response.body.index(@investigation_one.id.to_s)
  end
end
