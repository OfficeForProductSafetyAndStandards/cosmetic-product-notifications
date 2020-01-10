require "rails_helper"

RSpec.describe "Error page", type: :system, with_errors_rendered: true do
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }

  after do
    sign_out
  end

  it "is shown for 403 Forbidden response" do
    visit_unauthorised_page

    assert_text "Access denied"
  end

  it "is shown for 404 Not Found response" do
    visit_non_existent_page

    assert_text "Page not found"
  end

  it "is shown for 500 Server Error response" do
    trigger_server_error

    assert_text "Sorry, there is a problem with the service"
  end

private

  def visit_unauthorised_page
    sign_in_as_poison_centre_user
    visit responsible_person_notifications_path(responsible_person)
  end

  def visit_non_existent_page
    visit "/foo-bar"
  end

  def trigger_server_error
    sign_in_as_poison_centre_user
    visit poison_centre_notification_path(0)
  end
end
