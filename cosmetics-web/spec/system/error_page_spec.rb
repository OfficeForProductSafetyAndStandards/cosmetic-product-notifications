require "rails_helper"

RSpec.describe "Error page", type: :system do
  let(:responsible_person) { create(:responsible_person) }

  after do
    sign_out
  end

  it "is shown for 403 Forbidden response" do
    with_error_page_rendering do
      visit_unauthorised_page
    end

    assert_text "Access denied"
  end

  it "is shown for 404 Not Found response" do
    with_error_page_rendering do
      visit_non_existent_page
    end

    assert_text "Page not found"
  end

  it "is shown for 500 Server Error response" do
    with_error_page_rendering do
      trigger_server_error
    end

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
