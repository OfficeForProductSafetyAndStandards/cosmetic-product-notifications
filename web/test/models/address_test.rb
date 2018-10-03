require "test_helper"

class AddressTest < ActiveSupport::TestCase
  test "short displays correctly" do
    address = Address.new(locality: 'L', country: 'C')
    assert_equal 'L, C', address.short
  end

  test "short displays correctly when locality is blank" do
    address = Address.new(country: 'C')
    assert_equal 'C', address.short
  end
end
