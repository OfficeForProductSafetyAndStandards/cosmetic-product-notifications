require "test_helper"

class CorrespondenceControllerTest < ActionDispatch::IntegrationTest
  setup do
    @investigation = investigations(:one)
    sign_in_as_admin
  end

  teardown do
    logout
  end

  test "should create correspondence" do
    assert_difference("Correspondence.count") do
      post investigation_correspondences_path(@investigation), params: {
        correspondence: {
          overview: "Test correspondence"
        }
      }
    end
  end

  test "should add correspondence to investigation" do
    test_overview = "Test correspondence"
    post investigation_correspondences_path(@investigation), params: {
      correspondence: {
        overview: test_overview
      }
    }
    assert_equal(Investigation.first.correspondences.first.overview, test_overview)
  end
end
