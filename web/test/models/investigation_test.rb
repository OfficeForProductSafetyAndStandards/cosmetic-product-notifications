require "test_helper"

class InvestigationTest < ActiveSupport::TestCase
  setup do
    sign_in_as_user
  end

  teardown do
    logout
  end

  test "should create activities when investigation is created" do
    assert_difference"Activity.count" do
      add_investigation
      @investigation.save
    end
  end

  def add_investigation
    @investigation = Investigation.new
  end
end
