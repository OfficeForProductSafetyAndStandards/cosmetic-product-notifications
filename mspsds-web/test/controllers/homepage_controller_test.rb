require "test_helper"

class HomepageControllerTest < ActionDispatch::IntegrationTest
  setup do
    mock_out_keycloak_and_notify
  end

  teardown do
    reset_keycloak_and_notify_mocks
  end

  test "displays homepage for non_opss users" do
    set_user_as_non_opss(User.current)
    get "/"
    assert_response :success
  end

  test "redirects to /cases for opss users" do
    get "/"
    assert_redirected_to investigations_path
  end
end
