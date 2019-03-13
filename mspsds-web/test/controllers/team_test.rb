require "test_helper"

class TeamTest < ActionDispatch::IntegrationTest
  setup do
    mock_out_keycloak_and_notify

    @user_one = User.find_by(last_name: "User_one")
    @user_two = User.find_by(last_name: "User_two")
    @user_three = User.find_by(last_name: "User_three")
    @admin = User.find_by(last_name: "Admin")

    prepare_assigned_cases
  end

  teardown do
    reset_keycloak_and_notify_mocks
  end

  test "team users can see each other by get team members" do
    assert_same_elements User.get_team_members(user: @user_one).to_a, [@user_one, @admin, @user_two]
    assert_same_elements User.get_team_members(user: @admin).to_a, [@admin, @user_one]
    assert_same_elements User.get_team_members(user: @user_three).to_a, [@user_three]
  end

  test "assign filter returns all cases when no box is checked" do
    get investigations_path, params: {
      assigned_to_me: "unchecked",
      assigned_to_someone_else: "unchecked",
      assigned_to_someone_else_id: nil,
      assigned_to_team_0: nil,
      assigned_to_team_1: nil
    }
    assert_includes(response.body, @investigation_user_one.pretty_id)
    assert_includes(response.body, @investigation_admin.pretty_id)
    assert_includes(response.body, @investigation_user_three.pretty_id)
    assert_includes(response.body, @investigation_team_one.pretty_id)
    assert_includes(response.body, @investigation_team_three.pretty_id)
  end

  test "assign filter returns all cases when other is checked, not selected, and me is checked" do
    get investigations_path, params: {
      assigned_to_me: "checked",
      assigned_to_someone_else: "checked",
      assigned_to_someone_else_id: nil,
      assigned_to_team_0: nil,
      assigned_to_team_1: nil
    }
    assert_includes(response.body, @investigation_user_one.pretty_id)
    assert_includes(response.body, @investigation_admin.pretty_id)
    assert_includes(response.body, @investigation_user_three.pretty_id)
    assert_includes(response.body, @investigation_team_one.pretty_id)
    assert_includes(response.body, @investigation_team_three.pretty_id)
  end

  test "assign filter returns only cases assigned to current user when me is checked" do
    get investigations_path, params: {
      assigned_to_me: "checked",
      assigned_to_someone_else: "unchecked",
      assigned_to_someone_else_id: nil,
      assigned_to_team_0: nil,
      assigned_to_team_1: nil
    }
    assert_includes(response.body, @investigation_user_one.pretty_id)
    assert_not_includes(response.body, @investigation_admin.pretty_id)
    assert_not_includes(response.body, @investigation_user_three.pretty_id)
    assert_not_includes(response.body, @investigation_team_one.pretty_id)
    assert_not_includes(response.body, @investigation_team_three.pretty_id)
  end

  test "assign team filter returns only cases assigned to that team or its users when team is checked" do
    get investigations_path, params: {
      assigned_to_me: "unchecked",
      assigned_to_someone_else: "unchecked",
      assigned_to_someone_else_id: nil,
      assigned_to_team_0: @user_one.teams[0].id,
      assigned_to_team_1: nil
    }
    assert_includes(response.body, @investigation_user_one.pretty_id)
    assert_includes(response.body, @investigation_admin.pretty_id)
    assert_not_includes(response.body, @investigation_user_three.pretty_id)
    assert_includes(response.body, @investigation_team_one.pretty_id)
    assert_not_includes(response.body, @investigation_team_three.pretty_id)
  end

  test "assign team filter works with multiple teams" do
    get investigations_path, params: {
      assigned_to_me: "unchecked",
      assigned_to_someone_else: "checked",
      assigned_to_someone_else_id: all_teams[2].id,
      assigned_to_team_0: @user_one.teams[0].id,
      assigned_to_team_1: nil
    }
    assert_includes(response.body, @investigation_user_one.pretty_id)
    assert_includes(response.body, @investigation_admin.pretty_id)
    assert_includes(response.body, @investigation_user_three.pretty_id)
    assert_includes(response.body, @investigation_team_one.pretty_id)
    assert_includes(response.body, @investigation_team_three.pretty_id)
  end

  test "assign team filter works with multiple entities" do
    get investigations_path, params: {
      assigned_to_me: "unchecked",
      assigned_to_someone_else: "checked",
      assigned_to_someone_else_id: @user_three.id,
      assigned_to_team_0: @user_one.teams[0].id,
      assigned_to_team_1: nil
    }
    assert_includes(response.body, @investigation_user_one.pretty_id)
    assert_includes(response.body, @investigation_admin.pretty_id)
    assert_includes(response.body, @investigation_user_three.pretty_id)
    assert_includes(response.body, @investigation_team_one.pretty_id)
    assert_not_includes(response.body, @investigation_team_three.pretty_id)
  end

  test "select team should match check team" do
    get investigations_path, params: {
      assigned_to_me: "unchecked",
      assigned_to_someone_else: "checked",
      assigned_to_someone_else_id: @user_one.teams[0].id,
      assigned_to_team_0: nil,
      assigned_to_team_1: nil
    }
    assert_includes(response.body, @investigation_user_one.pretty_id)
    assert_includes(response.body, @investigation_admin.pretty_id)
    assert_not_includes(response.body, @investigation_user_three.pretty_id)
    assert_includes(response.body, @investigation_team_one.pretty_id)
    assert_not_includes(response.body, @investigation_team_three.pretty_id)
  end

  test "assign team filter returns only cases assigned to that team or its users when team is selected" do
    get investigations_path, params: {
      assigned_to_me: "unchecked",
      assigned_to_someone_else: "checked",
      assigned_to_someone_else_id: all_teams[2].id,
      assigned_to_team_0: nil,
      assigned_to_team_1: nil
    }
    assert_not_includes(response.body, @investigation_user_one.pretty_id)
    assert_not_includes(response.body, @investigation_admin.pretty_id)
    assert_includes(response.body, @investigation_user_three.pretty_id)
    assert_not_includes(response.body, @investigation_team_one.pretty_id)
    assert_includes(response.body, @investigation_team_three.pretty_id)
  end

  def prepare_assigned_cases
    investigation = Investigation.find_by(description: "Investigation one description")
    investigation.update(assignee: @user_one)
    @investigation_user_one = Investigation.find_by(description: "Investigation one description")
    assert_equal @investigation_user_one.assignee, @user_one

    investigation = Investigation.find_by(description: "Investigation two description")
    investigation.update(assignee: @admin)
    @investigation_admin = Investigation.find_by(description: "Investigation two description")
    assert_equal @investigation_admin.assignee, @admin

    investigation = Investigation.find_by(description: "Investigation for search by correspondence")
    investigation.update(assignee: @user_three)
    @investigation_user_three = Investigation.find_by(description: "Investigation for search by correspondence")
    assert_equal @investigation_user_three.assignee, @user_three

    investigation = Investigation.find_by(description: "Investigation with no product")
    investigation.update(assignee: all_teams[0])
    @investigation_team_one = Investigation.find_by(description: "Investigation with no product")
    assert_equal @investigation_team_one.assignee, all_teams[0]

    investigation = Investigation.find_by(description: "Investigation for search by product")
    investigation.update(assignee: all_teams[2])
    @investigation_team_three = Investigation.find_by(description: "Investigation for search by product")
    assert_equal @investigation_team_three.assignee, all_teams[2]
  end
end
