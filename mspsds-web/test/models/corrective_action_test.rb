require 'test_helper'

class CorrectiveActionTest < ActiveSupport::TestCase
  setup do
    @investigation = investigations(:one)
    @business = businesses(:one)
    @product = products(:one)
    sign_in_as_opss_user
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

  test "requires the summary to be no longer than 1000 characters" do
    more_than_1000_characters = "a" * 1001
    exactly_1000_characters = "a" * 1000

    corrective_action = CorrectiveAction.create(investigation: @investigation, business: @business, product: @product, date_decided: "2018-11-15")
    corrective_action.summary = more_than_1000_characters
    assert_not corrective_action.save, "expected validation errors when saving the record"
    corrective_action.summary = exactly_1000_characters
    assert corrective_action.save, "unexpected validation errors encountered when saving the record"
  end

  test "requires the details to be no longer than 1000 characters" do
    more_than_1000_characters = "a" * 1001
    exactly_1000_characters = "a" * 1000

    corrective_action = CorrectiveAction.create(investigation: @investigation, business: @business, product: @product, summary: "Test summary", date_decided: "2018-11-15")
    corrective_action.details = more_than_1000_characters
    assert_not corrective_action.save, "expected validation errors when saving the record"
    corrective_action.details = exactly_1000_characters
    assert corrective_action.save, "unexpected validation errors encountered when saving the record"
  end

  test "requires a date to be specified" do
    corrective_action = CorrectiveAction.create(investigation: @investigation, business: @business, product: @product, summary: "Test summary")
    assert_not corrective_action.save, "expected validation errors when saving the record"
    corrective_action.date_decided = "2018-11-16"
    assert corrective_action.save, "unexpected validation errors encountered when saving the record"
  end

  test "requires the date to not be in the future" do
    corrective_action = CorrectiveAction.create(investigation: @investigation, business: @business, product: @product, summary: "Test summary")
    corrective_action.date_decided = Time.zone.tomorrow
    assert_not corrective_action.save, "expected validation errors when saving the record"
    corrective_action.date_decided = Time.zone.today
    assert corrective_action.save, "unexpected validation errors encountered when saving the record"
  end

  test "creates an associated activity when created" do
    assert_difference "Activity.count" do
      corrective_action = CorrectiveAction.create(investigation: @investigation, business: @business, product: @product, summary: "Test summary", date_decided: "2018-11-15")
      corrective_action.save!
    end

    assert Activity.last.is_a? AuditActivity::CorrectiveAction::Add
  end
end
