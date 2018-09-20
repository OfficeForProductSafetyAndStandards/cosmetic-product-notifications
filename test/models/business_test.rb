require "test_helper"

class BusinessTest < ActiveSupport::TestCase
  test "Business requires a company name" do
    business = Business.new
    assert_not business.save
    business.company_name = 'Test'
    assert business.save
  end
end
