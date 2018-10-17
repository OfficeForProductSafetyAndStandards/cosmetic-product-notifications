require "test_helper"

class ReportControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as_admin
  end

  teardown do
    logout
  end

  test "should allow to add an investigation with just a reporter via post" do
    assert_difference("Investigation.count") do
      post report_index_url, params: {
        reporter: {
          reporter_type: "Business",
          name: "Test Name"
        }
      }
    end
  end

  test "should create a reporter" do
    assert_difference("Reporter.count") do
      post report_index_url, params: {
        reporter: {
          reporter_type: "Business",
          name: "Test Name"
        }
      }
    end
  end

  test "should redirect a get request to steps journey" do
    get new_report_url
    assert_redirected_to report_index_path + '/type'
  end
end
