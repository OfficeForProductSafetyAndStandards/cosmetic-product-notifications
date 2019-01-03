require "test_helper"

class ReporterTest < ActiveSupport::TestCase
  setup do
    @reporter = Reporter.new(reporter_type: "Business")
    sign_in_as_user
  end

  teardown do
    logout
  end

  test "should not allow reporter without an investigation" do
    assert_no_difference("Reporter.count") do
      @reporter.save
    end
  end

  test "should allow a reporter with an investigation" do
    assert_difference("Reporter.count") do
      add_investigation
      @reporter.save
    end
  end

  def add_investigation
    @investigation = Investigation.new
    @investigation.reporter = @reporter
  end
end
