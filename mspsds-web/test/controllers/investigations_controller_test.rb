require "test_helper"

class InvestigationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as_admin

    @investigation_one = investigations(:one)
    @investigation_one.created_at = Time.zone.parse('2014-07-11 21:00')
    @investigation_one.assignee = User.find_by(last_name: "Admin")
    @investigation_one.source = sources(:investigation_one)
    @investigation_one.save

    @investigation_two = investigations(:two)
    @investigation_two.created_at = Time.zone.parse('2015-07-11 21:00')
    @investigation_two.assignee = User.find_by(last_name: "User")
    @investigation_two.save

    @investigation_three = investigations(:three)
    @investigation_no_products = investigations(:no_products)

    # The updated_at values must be set separately in order to be respected
    @investigation_one.updated_at = Time.zone.parse('2017-07-11 21:00')
    @investigation_one.save
    @investigation_two.updated_at = Time.zone.parse('2016-07-11 21:00')
    @investigation_two.save

    Investigation.import refresh: true
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
    investigation_assignee_id = lambda { Investigation.find(@investigation_three.id).assignee_id }
    assert_changes investigation_assignee_id, from: nil, to: id do
      put assign_investigation_url(@investigation_three), params: {
        investigation: {
          assignee_id: id
        }
      }
    end
    assert_redirected_to investigation_url(@investigation_three)
  end

  test "should set status" do
    is_closed = true
    investigation_status = lambda { Investigation.find(@investigation_one.id).is_closed }
    assert_changes investigation_status, from: false, to: is_closed do
      put status_investigation_url(@investigation_one), params: {
          investigation: {
              is_closed: is_closed,
              status_rationale: "some rationale"
          }
      }
    end
    assert_redirected_to investigation_url(@investigation_one)
  end

  test "should require status to be open or closed" do
    put status_investigation_url(@investigation_one), params: {
      investigation: {
        status_rationale: "some rationale"
      }
    }
    assert_includes(response.body, "Status should be closed or open")
  end

  test "should update assignee from selectable list" do
    assignee = User.first
    put assign_investigation_url(@investigation_one), params: {
      investigation: {
        assignee_id: assignee.id
      }
    }
    assert_equal(Investigation.find(@investigation_one.id).assignee.id, assignee.id)
  end

  test "should update assignee from radio boxes" do
    assignee = User.first
    put assign_investigation_url(@investigation_one), params: {
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

  test "should return all investigations if both assignee checkboxes are unchecked" do
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

  test "should create excel file for list of investigations" do
    get investigations_path format: :xlsx
    assert_response :success
  end
end
