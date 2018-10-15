require "test_helper"

class InvestigationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as_admin
    @investigation = investigations(:one)
    @investigation.source = sources(:investigation_one)
    Investigation.import
  end

  teardown do
    logout
  end

  test "should get index" do
    get investigations_url
    assert_response :success
  end

  test "should get new" do
    get new_investigation_url
    assert_response :success
  end

  test "should create investigation" do
    assert_difference("Investigation.count") do
      post investigations_url, params: {
        investigation: {
          title: @investigation.title,
          description: @investigation.description,
          is_closed: @investigation.is_closed,
          source: @investigation.source,
          reporter_type: @investigation.reporter_type
        }
      }
    end

    assert_redirected_to investigation_url(Investigation.first)
  end

  test "should show investigation" do
    get investigation_url(@investigation)
    assert_response :success
  end

  test "should generate investigation pdf" do
    get investigation_url(@investigation, format: :pdf)
    assert_response :success
  end

  test "should get edit" do
    get edit_investigation_url(@investigation)
    assert_response :success
  end

  test "should update investigation" do
    patch investigation_url(@investigation), params: {
      investigation: {
        title: @investigation.title,
        description: @investigation.description,
        is_closed: @investigation.is_closed,
        source: @investigation.source,
        reporter_type: @investigation.reporter_type
      }
    }
    assert_redirected_to investigation_url(@investigation)
  end

  test "should destroy investigation" do
    assert_difference("Investigation.count", -1) do
      delete investigation_url(@investigation)
    end

    assert_redirected_to investigations_url
  end

  test "should redirect back to select reporter type with an error param if that field is empty" do
    post new_report_details_investigations_url, params: {
      investigation: {
        reporter_type: nil
      }
    }
    assert_redirected_to new_report_investigations_url(error: true)
  end

  test "should not redirect back to select reporter type if that field exists" do
    post new_report_details_investigations_url, params: {
      investigation: {
        reporter_type: 'Business'
      }
    }
    assert_response :success
  end

  test "should redirect to main page if user attempts to access the flow outside its beginning page" do
    get new_report_details_investigations_url
    assert_redirected_to investigations_path
  end

  test "should prompt to select type if receives errors" do
    get new_report_investigations_url(error: true)
    assert_not_empty(response.body.scan('Please select reporter type'))
  end

  test "should not prompt to select type if receives no errors" do
    get new_report_investigations_url
    assert_empty(response.body.scan('Please select reporter type'))
  end
end
