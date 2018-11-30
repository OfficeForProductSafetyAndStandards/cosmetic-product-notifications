require "test_helper"

class LocationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as_admin
    @location = locations(:one)
    @location.source = sources(:address_one)
  end

  teardown do
    logout
  end

  test "should get index" do
    get business_locations_url(@location.business)
    assert_response :success
  end

  test "should get new" do
    get new_business_location_url(@location.business)
    assert_response :success
  end

  test "should create location" do
    assert_difference("Location.count") do
      post business_locations_url(@location.business), params: {
        location: {
          name: @location.name,
          business_id: @location.business_id,
          country: @location.country,
          address: @location.address,
          phone_number: @location.phone_number,
          locality: @location.locality,
          postal_code: @location.postal_code
        }
      }
    end

    assert_redirected_to business_locations_url(@location.business)
  end

  test "should show location" do
    get location_url(@location)
    assert_response :success
  end

  test "should get edit" do
    get edit_location_url(@location)
    assert_response :success
  end

  test "should update location" do
    patch location_url(@location), params: {
      location: {
        name: @location.name,
        business_id: @location.business_id,
        country: @location.country,
        address: @location.address,
        phone_number: @location.phone_number,
        locality: @location.locality,
        postal_code: @location.postal_code
      }
    }
    assert_redirected_to location_url(@location)
  end

  test "should destroy location" do
    assert_difference("Location.count", -1) do
      delete location_url(@location)
    end

    assert_redirected_to business_locations_url(@location.business)
  end
end
