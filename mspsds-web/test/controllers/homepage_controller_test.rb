require "test_helper"

class HomepageControllerTest < ActionDispatch::IntegrationTest
  teardown do
    logout
  end

  test "displays homepage for non_opss users" do
    sign_in_as_non_opss_user
    get "/"
    assert_response :success
  end

  test "redirects to /cases for opss users" do
    sign_in_as_user
    get "/"
    assert_redirected_to investigations_path
  end
end
