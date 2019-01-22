require 'test_helper'

class ErrorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as_admin
  end

  teardown do
    logout
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
