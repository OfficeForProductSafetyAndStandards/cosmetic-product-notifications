require 'test_helper'

class ContactsControllerTest < ActionDispatch::IntegrationTest
  setup do
    mock_out_keycloak_and_notify(user_name: "Admin")
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
          job_title: @contact.job_title,
          email: @contact.email,
          name: @contact.name,
          phone_number: @contact.phone_number
        }
      }
    end

    assert_redirected_to business_url(@contact.business, anchor: "contacts")
  end

  test "should get edit" do
    get edit_business_contact_url(@contact, @contact.business)
    assert_response :success
  end

  test "should update contact" do
    patch business_contact_url(@contact.business, @contact), params: {
      contact: {
        job_title: "Job title/Description",
        email: "email@email.com",
        name: "John Smith",
        phone_number: "+4477619345346"
      }
    }
    assert_redirected_to business_url(@contact.business, anchor: "contacts")
  end

  test "should destroy contact" do
    assert_difference('Contact.count', -1) do
      delete business_contact_url(@contact.business, @contact)
    end

    assert_redirected_to business_url(@contact.business, anchor: "contacts")
  end
end
