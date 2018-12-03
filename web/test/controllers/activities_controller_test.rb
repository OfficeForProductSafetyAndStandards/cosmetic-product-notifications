require "test_helper"

class ActivitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as_admin
    @investigation = investigations(:one)
    @activity = activities(:one)
    @activity.source = sources(:activity_one)
  end

  teardown do
    logout
  end

  test "should create activity" do
    assert_difference("Activity.count") do
      post investigation_activities_url(@activity.investigation), params: {
        comment_activity: {
          body: @activity.body
        }
      }
    end

    assert_redirected_to investigation_url(@activity.investigation)
  end

  test "comment should go to comment page" do
    post add_investigation_activities_path(@investigation), params: {
      activity_type: "comment"
    }

    assert_redirected_to new_investigation_activity_path(@investigation)
  end

  test "correspondence should go to new correspondence page" do
    post add_investigation_activities_path(@investigation), params: {
      activity_type: "correspondence"
    }

    assert_redirected_to new_investigation_correspondence_path(@investigation)
  end

  test "product should go to new product page" do
    post add_investigation_activities_path(@investigation), params: {
      activity_type: "product"
    }

    assert_redirected_to new_investigation_product_path(@investigation)
  end

  test "request test should go to request test page" do
    post add_investigation_activities_path(@investigation), params: {
      activity_type: "testing_request"
    }

    assert_redirected_to new_request_investigation_tests_path(@investigation)
  end

  test "test result should go to test result page" do
    post add_investigation_activities_path(@investigation), params: {
      activity_type: "testing_result"
    }

    assert_redirected_to new_result_investigation_tests_path(@investigation)
  end

  test "corrective action should go to test corrective action page" do
    post add_investigation_activities_path(@investigation), params: {
      activity_type: "corrective_action"
    }

    assert_redirected_to new_investigation_corrective_action_path(@investigation)
  end

  test "business should go to new business page" do
    post add_investigation_activities_path(@investigation), params: {
      activity_type: "business"
    }

    assert_redirected_to new_investigation_business_path(@investigation)
  end
end
