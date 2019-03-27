require 'test_helper'

class CorrectiveActionTest < ActiveSupport::TestCase
  setup do
    @investigation = investigations(:one)
    @business = businesses(:one)
    @product = products(:one)
    mock_out_keycloak_and_notify
    accept_declaration
  end

  teardown do
    reset_keycloak_and_notify_mocks
  end

  test "requires an associated investigation, business and product" do
    corrective_action = create_valid_corrective_action
    corrective_action.update(investigation: nil, business: nil, product: nil)
    assert_not corrective_action.save, "expected validation errors when saving the record"
    corrective_action.investigation = @investigation
    assert_not corrective_action.save, "expected validation errors when saving the record"
    corrective_action.business = @business
    assert_not corrective_action.save, "expected validation errors when saving the record"
    corrective_action.product = @product
    assert corrective_action.save, "unexpected validation errors encountered when saving the record"
  end

  test "requires a summary to be specified" do
    corrective_action = create_valid_corrective_action
    corrective_action.summary = nil
    assert_not corrective_action.save, "expected validation errors when saving the record"
  end

  test "requires the summary to be no longer than 10000 characters" do
    more_than_10000_characters = "a" * 10001
    exactly_10000_characters = "a" * 10000

    corrective_action = create_valid_corrective_action
    corrective_action.summary = more_than_10000_characters
    assert_not corrective_action.save, "expected validation errors when saving the record"
    corrective_action.summary = exactly_10000_characters
    assert corrective_action.save, "unexpected validation errors encountered when saving the record"
  end

  test "requires the details to be no longer than 50000 characters" do
    more_than_50000_characters = "a" * 50001
    exactly_50000_characters = "a" * 50000

    corrective_action = create_valid_corrective_action
    corrective_action.details = more_than_50000_characters
    assert_not corrective_action.save, "expected validation errors when saving the record"
    corrective_action.details = exactly_50000_characters
    assert corrective_action.save, "unexpected validation errors encountered when saving the record"
  end

  test "requires a date to be specified" do
    corrective_action = create_valid_corrective_action
    corrective_action.clear_date
    assert_not corrective_action.save, "expected validation errors when saving the record"
  end

  test "requires the date to not be in the future" do
    corrective_action = create_valid_corrective_action
    corrective_action.set_date(Time.zone.tomorrow)
    assert_not corrective_action.save, "expected validation errors when saving the record"
    corrective_action.set_date(Time.zone.today)
    assert corrective_action.save, "unexpected validation errors encountered when saving the record"
  end

  test "requires the file to not be provided, or for the flag to be set to no file" do
    corrective_action = create_valid_corrective_action

    # related_file flag must be set
    corrective_action.related_file = nil
    assert_not corrective_action.save, "expected validation errors when saving the record"

    # if it's true, a file must be provided
    corrective_action.related_file = "Yes"
    assert_not corrective_action.save, "expected validation errors when saving the record"
    test_image = file_fixture("testImage.png")
    corrective_action.documents.attach(io: File.open(test_image), filename: 'testImage.png')
    assert corrective_action.save, "unexpected validation errors encountered when saving the record"
  end

  test "creates an associated activity when created" do
    assert_difference "Activity.count" do
      corrective_action = create_valid_corrective_action
      corrective_action.save!
    end

    assert Activity.last.is_a? AuditActivity::CorrectiveAction::Add
  end

private

  def create_valid_corrective_action
    CorrectiveAction.create(
      investigation: @investigation,
      business: @business,
      product: @product,
      summary: "Test summary",
      date_decided: "2018-11-15",
      legislation: "Legislation A",
      related_file: "No"
    )
  end
end
