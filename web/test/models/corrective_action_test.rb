require 'test_helper'

class CorrectiveActionTest < ActiveSupport::TestCase
  setup do
    @investigation = investigations(:one)
    @business = businesses(:one)
    @product = products(:one)
  end

  test "requires an associated investigation, business and product" do
    corrective_action = CorrectiveAction.create(date_decided: "2018-11-15", summary: "Test summary")
    assert_not corrective_action.save, "expected validation errors when saving the record"
    corrective_action.investigation = @investigation
    assert_not corrective_action.save, "expected validation errors when saving the record"
    corrective_action.business = @business
    assert_not corrective_action.save, "expected validation errors when saving the record"
    corrective_action.product = @product
    assert corrective_action.save, "unexpected validation errors encountered when saving the record"
  end

  test "requires a summary to be specified" do
    corrective_action = CorrectiveAction.create(investigation: @investigation, business: @business, product: @product, date_decided: "2018-11-15")
    assert_not corrective_action.save, "expected validation errors when saving the record"
    corrective_action.summary = "Test summary"
    assert corrective_action.save, "unexpected validation errors encountered when saving the record"
  end

  test "requires a date to be specified" do
    corrective_action = CorrectiveAction.create(investigation: @investigation, business: @business, product: @product, summary: "Test summary")
    assert_not corrective_action.save, "expected validation errors when saving the record"
    corrective_action.date_decided = "2018-11-16"
    assert corrective_action.save, "unexpected validation errors encountered when saving the record"
  end

  test "requires the date decided to not be in the future" do
    corrective_action = CorrectiveAction.create(investigation: @investigation, business: @business, product: @product, summary: "Test summary")
    corrective_action.date_decided = Date.tomorrow
    assert_not corrective_action.save, "expected validation errors when saving the record"
    corrective_action.date_decided = Date.today
    assert corrective_action.save, "unexpected validation errors encountered when saving the record"
  end
end
