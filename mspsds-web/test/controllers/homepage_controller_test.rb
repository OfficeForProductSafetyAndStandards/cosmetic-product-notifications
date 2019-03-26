require "test_helper"

class HomepageControllerTest < ActionDispatch::IntegrationTest
  setup do
    mock_out_keycloak_and_notify
    accept_declaration
  end

  teardown do
    reset_keycloak_and_notify_mocks
  end

  test "displays introduction for non_opss users who have not viewed introduction before" do
    mock_user_as_non_opss(User.current)
    get "/"
    assert_redirected_to introduction_overview_path
  end

  test "displays homepage for non_opss users who have viewed introduction before" do
    mock_user_as_non_opss(User.current)
    allow(User.current).to receive(:has_viewed_introduction).and_return true

    get '/'
    assert_response :success
  end

  test "redirects to /cases for opss users" do
    get "/"
    assert_redirected_to investigations_path
  end
end
