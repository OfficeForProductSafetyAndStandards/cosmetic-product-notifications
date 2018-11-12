require "test_helper"

class InvestigationTest < ActiveSupport::TestCase
  setup do
    sign_in_as_user
  end

  teardown do
    logout
  end

  test "should create activities when investigation is created" do
    # One for case created, one for assigning current user to it
    assert_difference("Activity.count", 2) do
      add_investigation
      @investigation.save
    end
  end

  def add_investigation
    @investigation = Investigation.new
  end
end
