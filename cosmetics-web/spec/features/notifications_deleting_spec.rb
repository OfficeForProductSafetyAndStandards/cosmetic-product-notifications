require "rails_helper"

RSpec.describe "Notifications delete", type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:user) { responsible_person.responsible_person_users.first.user }
  let(:draft_notification) { create(:draft_notification, responsible_person: responsible_person) }

  before do
    configure_requests_for_submit_domain
    draft_notification
    sign_in user
  end

  scenario "deleting draft notification" do
    visit "/responsible_persons/#{responsible_person.id}/notifications"
    click_on "Incomplete (1)"
    click_on draft_notification.product_name
    click_on "Delete this cosmetics product"
    expect(page).to have_h1("Are you sure you want to delete #{draft_notification.product_name}")
    click_button "Delete notification"

    assert_text "#{draft_notification.product_name} notification deleted"
  end
end
