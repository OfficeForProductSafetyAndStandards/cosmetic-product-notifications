require 'test_helper'

class ErrorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    mock_out_keycloak_and_notify(user_name: "Admin")
  end

  teardown do
    reset_keycloak_and_notify_mocks
  end

  test "should get not_found" do
    get "/404"
    assert_response :not_found
  end

  test "should get internal_server_error" do
    get "/500"
    assert_response :internal_server_error
  end

  test "should get service_unavailable" do
    get "/503"
    assert_response :service_unavailable
  end
end
