require "test_helper"

class ActivitiesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    # TODO MSPSDS_197: figure out how to move this to User model without
    # build breaking (on db creation or docker-compose up)
    User.import force: true

    sign_in_as_admin
    @activity = activities(:one)
    @activity.source = sources(:activity_one)
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
          activity_type: @activity.activity_type,
          investigation_id: @activity.investigation_id,
          notes: @activity.notes
        }
      }
    end

    assert_redirected_to investigation_activities_url(@activity.investigation)
  end
end
