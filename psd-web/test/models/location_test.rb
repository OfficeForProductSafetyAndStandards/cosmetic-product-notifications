require "test_helper"

class LocationTest < ActiveSupport::TestCase
  test "short displays correctly" do
    location = Location.new(county: 'L', country: 'C')
    assert_equal 'L, C', location.short
  end

  test "short displays correctly when locality is blank" do
    location = Location.new(country: 'C')
    assert_equal 'C', location.short
  end
end
