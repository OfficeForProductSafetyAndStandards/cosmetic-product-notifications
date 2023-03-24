require "rails_helper"

RSpec.describe "Notifications delete", type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:user) { responsible_person.responsible_person_users.first.user }
  let(:draft_notification) { create(:draft_notification, responsible_person:) }
  let(:notification) { create(:registered_notification, responsible_person:) }

  before do
    configure_requests_for_submit_domain
    sign_in user
  end

  scenario "deleting draft notification" do
    draft_notification
    visit "/responsible_persons/#{responsible_person.id}/draft-notifications"
    click_on draft_notification.product_name
    click_on "Delete this draft"

    expect(page).to have_h1("Do you want to delete this draft?")
    expect(page).to have_text("The #{draft_notification.product_name} product notification draft will be deleted.")
    click_button "Delete"

    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link("Select yes if you want to delete this draft", href: "#yes")
    check "Yes"
    click_button "Delete"

    assert_text "#{draft_notification.product_name} notification deleted"
  end

  scenario "deleting submitted notification" do
    notification
    visit "/responsible_persons/#{responsible_person.id}/notifications"
    click_on "View #{notification.product_name}"
    click_on "Delete this notification"

    expect(page).to have_h1("Do you want to delete this notification?")
    expect(page).to have_text("The #{notification.product_name} product notification will be deleted.")
    click_button "Delete"

    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link("Select yes if you want to delete this notification", href: "#yes")
    check "Yes"
    click_button "Delete"

    assert_text "#{notification.product_name} notification deleted"

    log = NotificationDeleteLog.first
    expect(log.notification_product_name).to eq notification.product_name
  end

  scenario "not being able to delete a submitted notification outside its deletion window" do
    notification = create(:registered_notification,
                          responsible_person:,
                          notification_complete_at: 1.month.ago)
    visit "/responsible_persons/#{responsible_person.id}/notifications"
    click_on "View #{notification.product_name}"
    expect(page).not_to have_link("Delete this notification")
  end
end
