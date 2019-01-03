require 'test_helper'

class TestTest < ActiveSupport::TestCase
  setup do
    @investigation = investigations(:one)
    @product = products(:one)
    sign_in_as_user
  end

  teardown do
    logout
  end

  test "requires an associated investigation and product" do
    test_request = Test::Request.create(date: "2018-11-08")
    assert_not test_request.save
    test_request.investigation = @investigation
    assert_not test_request.save
    test_request.product = @product
    assert test_request.save
  end

  test "requires a date to be specified" do
    test_request = Test::Request.create(investigation: @investigation, product: @product)
    assert_not test_request.save
    test_request.date = "2018-11-08"
    assert test_request.save
  end

  test "requires the details to be no longer than 1000 characters" do
    more_than_1000_characters = "a" * 1001
    exactly_1000_characters = "a" * 1000

    test_request = Test::Request.create(investigation: @investigation, product: @product, date: "2018-11-08")
    test_request.details = more_than_1000_characters
    assert_not test_request.save
    test_request.details = exactly_1000_characters
    assert test_request.save
  end

  test "test result requires result to be specified" do
    test_request = Test::Result.create(investigation: @investigation, product: @product, date: "2018-11-08")
    assert_not test_request.save
    test_request.result = "Fail"
    assert test_request.save
  end

  test "should create activity when test request is created" do
    assert_difference "Activity.count" do
      test_request = Test::Request.create(investigation: @investigation, product: @product, date: "2018-11-08")
      test_request.save!
    end
  end

  test "should create activity when test result is created" do
    assert_difference "Activity.count" do
      test_result = Test::Result.create(investigation: @investigation, product: @product, date: "2018-11-08", result: "Pass")
      test_result.save!
    end
  end

  test "should return correct requested state" do
    test_request = Test::Request.create(investigation: @investigation, product: @product, date: "2018-11-08")
    test_result = Test::Result.create(investigation: @investigation, product: @product, date: "2018-11-08", result: "Pass")

    assert test_request.requested?
    assert_not test_result.requested?
  end
end
