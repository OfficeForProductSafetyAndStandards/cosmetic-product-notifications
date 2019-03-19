require "test_helper"

class HomepageControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = mock_out_keycloak_and_notify
  end

  teardown do
    reset_keycloak_and_notify_mocks
  end

  test "displays introduction for non_opss users who have not viewed introduction before" do
    set_user_as_non_opss(@user)
    get "/"
    assert_redirected_to introduction_overview_path
  end

  test "displays homepage for non_opss users who have viewed introduction before" do
    set_user_as_non_opss(@user)
    allow(@user).to receive(:has_viewed_introduction).and_return true

    get '/'
    assert_response :success
  end

  test "redirects to /cases for opss users" do
    get "/"
    assert_redirected_to investigations_path
  end
end
