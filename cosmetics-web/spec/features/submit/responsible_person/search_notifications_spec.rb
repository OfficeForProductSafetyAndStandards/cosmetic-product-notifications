require "rails_helper"
require "support/feature_helpers"

RSpec.describe "Search notifications page", type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:submit_user) { responsible_person.responsible_person_users.first.user }

  let(:cream) { create(:notification, :registered, :with_component, notification_complete_at: 1.day.ago, product_name: "Cream", responsible_person:) }
  let(:lotion) { create(:notification, :registered, :with_component, notification_complete_at: 1.day.ago, product_name: "Lotion", responsible_person:) }

  before do
    configure_requests_for_submit_domain
    cream
    lotion
    Notification.import_to_opensearch(force: true)
    sign_in_as_member_of_responsible_person(responsible_person, submit_user)
  end

  scenario "searching for a notification by name" do
    visit responsible_person_search_notifications_path(responsible_person.id)
    expect(page).to have_h1("Product – search")

    fill_in "notification_search_form[q]", with: "Cream"
    click_button "Search"

    expect(page).to have_h1("Product – search results")
    expect(page).to have_text("Cream")
    expect(page).not_to have_text("Lotion")
  end

  scenario "Editing your search" do
    visit responsible_person_search_notifications_path(responsible_person.id)

    fill_in "notification_search_form[q]", with: "Cream"
    click_button "Search"
    click_button "Edit your search"

    expect(page).to have_field("notification_search_form[q]", with: "Cream")
  end
end
