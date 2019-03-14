require "test_helper"

class TeamsControllerTest < ActionDispatch::IntegrationTest
  setup do
    mock_out_keycloak_and_notify
    set_user_as_team_admin(User.current)
    @my_team = User.current.teams.first
    @another_team = Team.all.find { |t| !User.current.teams.include?(t) }
    @users_in_my_org = User.current.organisation.users.reject {|u| u == User.current}
    @user_in_my_org_not_team = @users_in_my_org.find {|u| (u.teams & User.current.teams).empty?}
  end

  teardown do
    reset_keycloak_and_notify_mocks
  end

  test "Team pages are visible to members" do
    get team_url(@my_team)
    assert_response :success
  end

  test "Team pages are not visible to non-members" do
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
    email_address = @user_in_my_org_not_team.email
    assert_difference "@my_team.users.count" => 1, "User.count" => 0 do
      put team_url(@my_team), params: { new_user: {
          email_address: email_address
      } }
      assert_response :success
    end
    expect(NotifyMailer).to have_received(:user_added_to_team)
                                .with(hash_including(email: email_address, team_id: @my_team.id))
  end

  test "Inviting existing user from same team returns error" do
    # TODO
  end

  test "Inviting to team I'm not a member of is forbidden" do
    # TODO
  end

  test "Inviting existing user from different org doesn't add and shows error" do
    # TODO
  end

  test "Inviting new user creates the account and adds them to the team" do
    # TODO
    # Check added
    # Check email sent
  end
end
