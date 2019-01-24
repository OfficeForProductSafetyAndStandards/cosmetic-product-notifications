require 'test_helper'

class ContactsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as_admin
    @contact = contacts(:one)
  end

  test "should get new" do
    get new_business_contact_url(@contact.business)
    assert_response :success
  end

  test "should create contact" do
    assert_difference('Contact.count') do
      post business_contacts_url(@contact.business), params: {
        contact: {
          description: @contact.description,
          email: @contact.email,
          name: @contact.name,
          phone_number: @contact.phone_number
        }
      }
    end

    assert_redirected_to business_url(@contact.business, anchor: "contacts")
  end

  test "should get edit" do
    get edit_contact_url(@contact)
    assert_response :success
  end

  test "should update contact" do
    patch contact_url(@contact), params: {
      contact: {
        description: "Job title/Description",
        email: "email@email.com",
        name: "John Smith",
        phone_number: "+4477619345346"
      }
    }
    assert_redirected_to business_url(@contact.business, anchor: "contacts")
  end

  test "should destroy contact" do
    assert_difference('Contact.count', -1) do
      delete contact_url(@contact)
    end

    assert_redirected_to business_url(@contact.business, anchor: "contacts")
  end
end
