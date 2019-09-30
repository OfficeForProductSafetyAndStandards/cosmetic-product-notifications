require "test_helper"

class EnquiryTest < ActiveSupport::TestCase
  include Pundit
    # Pundit requires this method to be able to call policies
  def pundit_user
    User.current
  end

  setup do
    mock_out_keycloak_and_notify
  end

  teardown do
    reset_keycloak_and_notify_mocks
  end

  test "Enquiry with valid date received" do
    investigation = Investigation::Enquiry.new("date_received_day" => 1, "date_received_month" => 1, "date_received_year" => 1)
    assert(investigation.valid?)
  end

  test "Enquiry date received can be nil, for old enquiries" do
    investigation = load_case(:enquiry)
    investigation.date_received = nil
    assert(investigation.valid?)
  end

  test "Enquiry date received cannot be in the future" do
    investigation = Investigation::Enquiry.new("date_received" => Time.zone.today + 1.year)
    investigation.save
    assert(investigation.invalid?)
  end

  test "Enquiry date received cannot be in the future 2" do
    investigation = Investigation::Enquiry.new("date_received_day" => 1, "date_received_month" => 1, "date_received_year" => 9999)
    investigation.save
    assert(investigation.invalid?)
  end

  test "Enquiry date received cannot have empty fields" do
    investigation = Investigation::Enquiry.new("date_received_day" => 1, "date_received_month" => 1, "date_received_year" => "")
    investigation.save
    assert(investigation.invalid?)
  end

  test "Enquiry date received has to be a date" do
    investigation = Investigation::Enquiry.new("date_received_day" => "day", "date_received_month" => "month", "date_received_year" => "year")
    investigation.save
    assert(investigation.invalid?)
  end
end
