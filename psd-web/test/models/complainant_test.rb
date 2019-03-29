require "test_helper"

class ComplainantTest < ActiveSupport::TestCase
  setup do
    @complainant = Complainant.new(complainant_type: "Business")
    mock_out_keycloak_and_notify
  end

  teardown do
    reset_keycloak_and_notify_mocks
  end

  test "should not allow complainant without an investigation" do
    assert_no_difference("Complainant.count") do
      @complainant.save
    end
  end

  test "should allow a complainant with an investigation" do
    assert_difference("Complainant.count") do
      add_investigation
      @complainant.save
    end
  end

  def add_investigation
    @investigation = Investigation::Allegation.new
    @investigation.complainant = @complainant
  end
end
