require "rails_helper"

RSpec.describe "Notifications delete", type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:user) { responsible_person.responsible_person_users.first.user }
  let(:draft_notification) { create(:draft_notification, responsible_person: responsible_person) }
  let(:notification) { create(:registered_notification, responsible_person: responsible_person) }

  before do
    configure_requests_for_submit_domain
    sign_in user
  end

  scenario "deleting draft notification" do
    draft_notification
    visit "/responsible_persons/#{responsible_person.id}/notifications"
    click_on draft_notification.product_name
    click_on "Delete this incomplete notification"
    expect(page).to have_h1("Are you sure you want to delete #{draft_notification.product_name}?")
    click_button "Delete notification"

    assert_text "#{draft_notification.product_name} notification deleted"
  end

  scenario "deleting submited notification" do
    notification
    visit "/responsible_persons/#{responsible_person.id}/notifications"
    click_on notification.product_name
    click_on "Delete this notification"
    expect(page).to have_h1("Are you sure you want to delete #{notification.product_name}?")
    click_button "Delete notification"

    assert_text "#{notification.product_name} notification deleted"

    log = NotificationDeleteLog.first
    expect(log.notification_product_name).to eq notification.product_name
  end

  scenario "not being able to delete a submitted notification outside its deletion window" do
    notification = create(:registered_notification,
                          responsible_person: responsible_person,
                          notification_complete_at: 1.month.ago)
    visit "/responsible_persons/#{responsible_person.id}/notifications"
    click_on notification.product_name
    expect(page).not_to have_link("Delete this cosmetic product notification")
  end
end
