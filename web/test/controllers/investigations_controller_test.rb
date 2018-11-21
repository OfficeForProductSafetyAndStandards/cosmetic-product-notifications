require "test_helper"

class InvestigationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as_admin
    @investigation = investigations(:one)
    @investigation_two = investigations(:two)
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

  test "status filter should be defaulted to open" do
    get investigations_path
    assert_not_includes(response.body, investigations(:three).pretty_id)
    assert_includes(response.body, investigations(:one).pretty_id)
    assert_includes(response.body, investigations(:two).pretty_id)
    assert_includes(response.body, investigations(:no_products).pretty_id)
  end

  test "status filter for both open and closed checked" do
    get investigations_path, params: {
      status_open: "checked",
      status_closed: "checked"
    }
    assert_includes(response.body, investigations(:three).pretty_id)
    assert_includes(response.body, investigations(:one).pretty_id)
    assert_includes(response.body, investigations(:two).pretty_id)
    assert_includes(response.body, investigations(:no_products).pretty_id)
  end

  test "status filter for both open and closed unchecked" do
    get investigations_path, params: {
      status_open: "unchecked",
      status_closed: "unchecked"
    }
    assert_includes(response.body, investigations(:three).pretty_id)
    assert_includes(response.body, investigations(:one).pretty_id)
    assert_includes(response.body, investigations(:two).pretty_id)
    assert_includes(response.body, investigations(:no_products).pretty_id)
  end

  test "status filter for only open checked" do
    get investigations_path, params: {
      status_open: "checked",
      status_closed: "unchecked"
    }
    assert_not_includes(response.body, investigations(:three).pretty_id)
    assert_includes(response.body, investigations(:one).pretty_id)
    assert_includes(response.body, investigations(:two).pretty_id)
    assert_includes(response.body, investigations(:no_products).pretty_id)
  end

  test "status filter for only closed checked" do
    get investigations_path, params: {
      status_open: "unchecked",
      status_closed: "checked"
    }
    assert_includes(response.body, investigations(:three).pretty_id)
    assert_not_includes(response.body, investigations(:one).pretty_id)
    assert_not_includes(response.body, investigations(:two).pretty_id)
    assert_not_includes(response.body, investigations(:no_products).pretty_id)
  end

  test "should return all investigations if both assignee checkboxes are unchecked" do
    User.all
    admin_user = User.find_by(last_name: "Admin")
    test_user = User.find_by(last_name: "User")

    @investigation.assignee = admin_user
    @investigation.save
    @investigation_two.assignee = test_user
    @investigation_two.save

    get investigations_path, params: {
        assigned_to_me: "unchecked",
        assigned_to_someone_else: "unchecked",
        status_open: "unchecked",
        status_closed: "unchecked"
    }
    assert_includes(response.body, investigations(:one).pretty_id)
    assert_includes(response.body, investigations(:two).pretty_id)
    assert_includes(response.body, investigations(:three).pretty_id)
  end

  test "should return all investigations if both assignee checkboxes are checked and name input is blank" do
    User.all
    admin_user = User.find_by(last_name: "Admin")
    test_user = User.find_by(last_name: "User")

    @investigation.assignee = admin_user
    @investigation.save
    @investigation_two.assignee = test_user
    @investigation_two.save

    get investigations_path, params: {
        assigned_to_me: "checked",
        assigned_to_someone_else: "checked",
        assigned_to_someone_else_id: nil,
        status_open: "unchecked",
        status_closed: "unchecked"
    }
    assert_includes(response.body, investigations(:one).pretty_id)
    assert_includes(response.body, investigations(:two).pretty_id)
    assert_includes(response.body, investigations(:three).pretty_id)
  end

  test "should return investigations assigned to current user if only the 'Me' checkbox is checked" do
    User.all
    admin_user = User.find_by(last_name: "Admin")
    test_user = User.find_by(last_name: "User")

    @investigation.assignee = admin_user
    @investigation.save
    @investigation_two.assignee = test_user
    @investigation_two.save

    get investigations_path, params: {
        assigned_to_me: "checked",
        assigned_to_someone_else: "unchecked",
        assigned_to_someone_else_id: nil,
        status_open: "unchecked",
        status_closed: "unchecked"
    }
    assert_includes(response.body, investigations(:one).pretty_id)
    assert_not_includes(response.body, investigations(:two).pretty_id)
    assert_not_includes(response.body, investigations(:three).pretty_id)
  end

  test "should return investigations assigned to current user or given user if both checkboxes are checked
              and a user is given in the input" do
    User.all
    admin_user = User.find_by(last_name: "Admin")
    test_user = User.find_by(last_name: "User")

    @investigation.assignee = admin_user
    @investigation.save
    @investigation_two.assignee = test_user
    @investigation_two.save

    get investigations_path, params: {
        assigned_to_me: "checked",
        assigned_to_someone_else: "checked",
        assigned_to_someone_else_id: @investigation_two.assignee_id,
        status_open: "unchecked",
        status_closed: "unchecked"
    }
    assert_includes(response.body, investigations(:one).pretty_id)
    assert_includes(response.body, investigations(:two).pretty_id)
    assert_not_includes(response.body, investigations(:three).pretty_id)
  end

  test "should return investigations assigned to a given user if only 'someone else' checkbox is checked
              and a user is given in the input" do
    User.all
    admin_user = User.find_by(last_name: "Admin")
    test_user = User.find_by(last_name: "User")

    @investigation.assignee = admin_user
    @investigation.save
    @investigation_two.assignee = test_user
    @investigation_two.save

    get investigations_path, params: {
        assigned_to_me: "unchecked",
        assigned_to_someone_else: "checked",
        assigned_to_someone_else_id: @investigation_two.assignee_id,
        status_open: "unchecked",
        status_closed: "unchecked"
    }
    assert_not_includes(response.body, investigations(:one).pretty_id)
    assert_includes(response.body, investigations(:two).pretty_id)
    assert_not_includes(response.body, investigations(:three).pretty_id)
  end

  test "should return investigations assigned to anyone except current user if only 'someone else' checkbox
              is checked and no user is given in the input" do
    User.all
    admin_user = User.find_by(last_name: "Admin")
    test_user = User.find_by(last_name: "User")

    @investigation.assignee = admin_user
    @investigation.save
    @investigation_two.assignee = test_user
    @investigation_two.save

    get investigations_path, params: {
        assigned_to_me: "unchecked",
        assigned_to_someone_else: "checked",
        assigned_to_someone_else_id: nil,
        status_open: "unchecked",
        status_closed: "unchecked"
    }
    assert_not_includes(response.body, investigations(:one).pretty_id)
    assert_includes(response.body, investigations(:two).pretty_id)
    assert_includes(response.body, investigations(:three).pretty_id)
  end
end
