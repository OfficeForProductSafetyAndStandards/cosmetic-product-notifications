require "test_helper"

class BusinessTest < ActiveSupport::TestCase
  test "Business requires a trading name" do
    business = Business.new
    assert_not business.save
    business.trading_name = 'Test'
    assert business.save
  end
end
