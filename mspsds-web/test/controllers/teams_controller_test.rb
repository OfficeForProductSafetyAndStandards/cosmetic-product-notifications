require "test_helper"

class TeamsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as_user(team_admin: true)
    @my_team = User.current.teams.first
    @another_team = Team.all.find { |t| !User.current.teams.include?(t) }
  end

  teardown do
    logout
  end

  test "Team pages are visible to members only" do
    assert_raises Pundit::NotAuthorizedError do
      get team_url(@another_team)
    end

    assert_raises Pundit::NotAuthorizedError do
      get invite_to_team_url(@another_team)
    end
  end

  test "Team invite pages are visible to users with team_admin role only" do
    set_user_as_not_team_admin

    assert_raises Pundit::NotAuthorizedError do
      get invite_to_team_url(@my_team)
    end
  end

  test "Inviting existing user from same org adds them to the team" do
    # Check added
    # Check email sent
  end

  test "Inviting to team I'm not a member of is forbidden" do
  end

  test "Inviting existing user from different org doesn't add and shows error" do

  end

  test "Inviting new user creates the account and adds them to the team" do
    # Check added
    # Check email sent
  end
end
