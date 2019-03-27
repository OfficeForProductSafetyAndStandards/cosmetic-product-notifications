require 'test_helper'

class TestTest < ActiveSupport::TestCase
  setup do
    @investigation = investigations(:one)
    @product = products(:one)
    mock_out_keycloak_and_notify
    accept_declaration
  end

  teardown do
    reset_keycloak_and_notify_mocks
  end

  test "requires an associated investigation and product" do
    test_request = create_valid_test_request
    test_request.investigation = nil
    test_request.product = nil

    assert_not test_request.save, "expected test to fail validation"
    test_request.investigation = @investigation
    assert_not test_request.save, "expected test to fail validation"
    test_request.product = @product
    assert test_request.save, "expected test to validate and save"
  end

  test "requires a date to be specified" do
    test_request = create_valid_test_request
    test_request.clear_date
    assert_not test_request.save, "expected test to fail validation"
  end

  test "requires the details to be no longer than 50000 characters" do
    more_than_50000_characters = "a" * 50001
    exactly_50000_characters = "a" * 50000

    test_request = create_valid_test_request
    test_request.details = more_than_50000_characters
    assert_not test_request.save, "expected test to fail validation"
    test_request.details = exactly_50000_characters
    assert test_request.save, "expected test to validate and save"
  end

  test "test result requires result to be specified" do
    test_result = create_valid_test_result
    test_result.result = nil
    assert_not test_result.save, "expected test to fail validation"
  end

  test "should create activity when test request is created" do
    assert_difference "Activity.count" do
      test_request = create_valid_test_request
      test_request.save!
    end
  end

  test "should create activity when test result is created" do
    assert_difference "Activity.count" do
      test_result = create_valid_test_result
      test_result.save!
    end
  end

  test "should return correct requested state" do
    test_request = create_valid_test_request
    test_result = create_valid_test_result

    assert test_request.requested?
    assert_not test_result.requested?
  end

private

  def create_valid_test_request
    Test::Request.create(
      investigation: @investigation,
      product: @product,
      date: "2018-11-08",
      legislation: "Legislation B"
    )
  end

  def create_valid_test_result
    result = Test::Result.create(
      investigation: @investigation,
      product: @product,
      date: "2018-11-08",
      result: "Pass",
      legislation: "Legislation B"
    )
    test_image = file_fixture("testImage.png")
    result.documents.attach(io: File.open(test_image), filename: 'testImage.png')
    result
  end
end
