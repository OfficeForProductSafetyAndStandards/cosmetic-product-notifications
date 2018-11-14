require 'test_helper'

class TestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @investigation = investigations(:one)
    @product = products(:one)
    sign_in_as_user
  end

  teardown do
    logout
  end

  test "should redirect new test request to first wizard step" do
    get new_request_investigation_tests_path(@investigation)
    assert_redirected_to investigation_tests_path(@investigation) + '/details'
  end

  test "should create test request" do
    assert_difference("Test.count") do
      post investigation_tests_path(@investigation), params: {
        test: {
          type: "Test::Request",
          product_id: @product.id,
          legislation: "Test Legislation",
          details: "Test Details",
          date: "12/11/2018"
        }
    }
    end

    assert_redirected_to investigation_url(@investigation)
  end

  test "should create test result" do
    assert_difference("Test.count") do
      post investigation_tests_path(@investigation), params: {
          test: {
              type: "Test::Result",
              product_id: @product.id,
              legislation: "Test Legislation",
              details: "Test Details",
              date: "12/11/2018",
              result: "Fail"
          }
      }
    end

    assert_redirected_to investigation_url(@investigation)
  end

  test "should add test record to investigation" do
    post investigation_tests_path(@investigation), params: {
        test: {
            type: "Test::Request",
            product_id: @product.id,
            legislation: "Test Legislation",
            details: "Test Details",
            date: "12/11/2018"
        }
    }

    assert_equal(Investigation.first.tests.last.legislation, "Test Legislation")
  end
end
