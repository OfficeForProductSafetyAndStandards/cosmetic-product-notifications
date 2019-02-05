require "test_helper"

class TeamTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as_user
    organisations = Organisation.all
    @teams = Team.all
    user_groups = User.all.map { |u| { id: u[:id], groups: [organisations[0][:id], @teams[0].id] } }.to_json
    allow(Keycloak::Internal).to receive(:get_user_groups).and_return(user_groups)

    TeamUser.all
    @user = User.find_by(last_name: "User_one")
    @admin = User.find_by(last_name: "Admin")
  end

  teardown do
    logout
  end

  test "team users can see each other by get team members" do
    assert_includes User.get_team_members(user: @user), @admin
    assert_includes User.get_team_members(user: @admin), @user
  end

  test "assigned to team filter returns cases assigned specifically to a given team" do
    investigation = Investigation.first
    team = @teams[0]
    investigation.assignee = team
    investigation.save
    get investigations_path, params: {
      assigned_to_me: "unchecked",
      assigned_to_someone_else: "unchecked",
      assigned_to_someone_else_id: nil,
      assigned_to_team_0: team.id,
      status_open: "unchecked",
      status_closed: "unchecked"
    }
    assert_includes(response.body, investigation.pretty_id)
  end

  test "assigned to team filter returns cases assigned to other users of a team" do
    investigation = Investigation.first
    team = @teams[0]
    investigation.assignee = @admin
    investigation.save
    get investigations_path, params: {
      assigned_to_me: "unchecked",
      assigned_to_someone_else: "unchecked",
      assigned_to_someone_else_id: nil,
      assigned_to_team_0: team.id,
      status_open: "unchecked",
      status_closed: "unchecked"
    }
    assert_includes(response.body, investigation.pretty_id)
  end

  test "assigned to team filter doesn't returns cases assigned a team if someone else is selected" do
    investigation = Investigation.first
    investigation.assignee = @admin
    investigation.save
    get investigations_path, params: {
      assigned_to_me: "unchecked",
      assigned_to_someone_else: "checked",
      assigned_to_someone_else_id: nil,
      status_open: "unchecked",
      status_closed: "unchecked"
    }
    assert_not_includes(response.body, investigation.pretty_id)
  end
end
