require "test_helper"

class ReporterTest < ActiveSupport::TestCase
  setup do
    sign_in_as_user
    @reporter = Reporter.new
  end

  teardown do
    @reporter = nil
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
