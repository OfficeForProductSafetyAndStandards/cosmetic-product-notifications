require "test_helper"

class AddressesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    # TODO MSPSDS_197: figure out how to move this to User model without
    # build breaking (on db creation or docker-compose up)
    User.import force: true

    sign_in_as_admin
    @address = addresses(:one)
    @address.source = sources(:address_one)
  end

  test "should get index" do
    get business_addresses_url(@address.business)
    assert_response :success
  end

  test "should get new" do
    get new_business_address_url(@address.business)
    assert_response :success
  end

  test "should create address" do
    assert_difference("Address.count") do
      post business_addresses_url(@address.business), params: {
        address: {
          address_type: @address.address_type,
          business_id: @address.business_id,
          country: @address.country,
          line_1: @address.line_1,
          line_2: @address.line_2,
          locality: @address.locality,
          postal_code: @address.postal_code
        }
      }
    end

    assert_redirected_to address_url(Address.last)
  end

  test "should show address" do
    get address_url(@address)
    assert_response :success
  end

  test "should get edit" do
    get edit_address_url(@address)
    assert_response :success
  end

  test "should update address" do
    patch address_url(@address), params: {
      address: {
        address_type: @address.address_type,
        business_id: @address.business_id,
        country: @address.country,
        line_1: @address.line_1,
        line_2: @address.line_2,
        locality: @address.locality,
        postal_code: @address.postal_code
      }
    }
    assert_redirected_to address_url(@address)
  end

  test "should destroy address" do
    assert_difference("Address.count", -1) do
      delete address_url(@address)
    end

    assert_redirected_to business_addresses_url(@address.business)
  end
end
