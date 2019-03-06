require "test_helper"

class TeamsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as_user
    @my_team = User.current.teams.first
    @another_team = Team.all.find { |t| !User.current.teams.include?(t) }
  end

  teardown do
    logout
  end

  test "Team pages are visible to members only" do
    get team_url(@my_team)
    assert_response :success

    assert_raises Pundit::NotAuthorizedError do
      get team_url(@another_team)
    end
  end

  test "Team invite pages are visible to members with team_admin privileges only" do

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
