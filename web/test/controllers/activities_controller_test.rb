require "test_helper"

class ActivitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as_admin
    @activity = activities(:one)
    @activity.source = sources(:activity_one)
  end

  teardown do
    logout
  end

  test "should get index" do
    get investigation_activities_url(@activity.investigation)
    assert_response :success
  end

  test "should get new" do
    get new_investigation_activity_url(@activity.investigation)
    assert_response :success
  end

  test "should create activity" do
    assert_difference("Activity.count") do
      post investigation_activities_url(@activity.investigation), params: {
        activity: {
          description: @activity.description
        }
      }
    end

    assert_redirected_to investigation_activities_url(@activity.investigation)
  end
end
