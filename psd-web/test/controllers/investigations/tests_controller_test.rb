require 'test_helper'

class TestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @investigation = load_case(:one)
    @product = products(:one)
    mock_out_keycloak_and_notify
  end

  teardown do
    reset_keycloak_and_notify_mocks
  end

  test "should redirect new test request action to first wizard step" do
    get new_request_investigation_tests_path(@investigation)
    assert_redirected_to investigation_tests_path(@investigation) + '/details'
  end

  test "should redirect new test result action to first wizard step" do
    get new_result_investigation_tests_path(@investigation)
    assert_redirected_to investigation_tests_path(@investigation) + '/details'
  end

  test "should create test request" do
    assert_difference("Test.count") do
      post investigation_tests_path(@investigation), params: {
        test: {
          is_result: false,
          product_id: @product.id,
          legislation: "Test Legislation",
          details: "Test Details",
          year: "2018",
          month: "11",
          day: "18"
        }
    }
    end

    assert Test.last.is_a?(Test::Request)

    assert_redirected_to investigation_url(@investigation)
  end

  test "should create test result" do
    assert_difference("Test.count") do
      post investigation_tests_path(@investigation), params: {
        test: {
          is_result: true,
          product_id: @product.id,
          legislation: "Test Legislation",
          details: "Test Details",
          year: "2018",
          month: "11",
          day: "18",
          result: "Fail",
          file: {
              file: fixture_file_upload('files/testImage.png', 'application/png')
          }
        }
      }
    end

    assert Test.last.is_a?(Test::Result)

    assert_redirected_to investigation_url(@investigation)
  end

  test "should add test record to investigation" do
    post investigation_tests_path(@investigation), params: {
      test: {
        is_result: false,
        product_id: @product.id,
        legislation: "Test Legislation",
        details: "Test Details",
        year: "2018",
        month: "11",
        day: "18"
      }
    }

    assert_equal(Investigation.first.tests.last.legislation, "Test Legislation")
  end
end
