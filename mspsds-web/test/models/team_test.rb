require "test_helper"

class TeamTest < ActiveSupport::TestCase
  setup do
    sign_in_as_user
    organisations = Organisation.all
    teams = Team.all
    user_groups = User.all.map { |u| { id: u[:id], groups: [organisations[0][:id], teams[0].id] } }.to_json
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
end
