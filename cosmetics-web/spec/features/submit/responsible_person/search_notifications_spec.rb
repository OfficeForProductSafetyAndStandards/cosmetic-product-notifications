require "rails_helper"
require "support/feature_helpers"

RSpec.describe "Search notifications page", type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:submit_user) { responsible_person.responsible_person_users.first.user }

  let(:cream) { create(:notification, :registered, :with_component, notification_complete_at: 1.day.ago, product_name: "Cream", responsible_person:) }
  let(:lotion) { create(:notification, :registered, :with_component, notification_complete_at: 1.day.ago, product_name: "Lotion", responsible_person:) }
  let(:paste) { create(:notification, :registered, :with_component, notification_complete_at: 1.day.ago, product_name: "Paste", industry_reference: "blend40", responsible_person:) }
  let(:powder) { create(:archived_notification, :with_component, notification_complete_at: 1.day.ago, product_name: "Powder", responsible_person:) }

  before do
    configure_requests_for_submit_domain

    cream
    lotion
    paste
    powder

    sign_in_as_member_of_responsible_person(responsible_person, submit_user)
  end

  scenario "Searching for a notification by name" do
    visit responsible_person_search_notifications_path(responsible_person.id)
    expect(page).to have_h1("Product – search")

    fill_in "notification_search_form[q]", with: "Cream"
    click_button "Search"

    expect(page).to have_h1("Product – search results")
    expect(page).to have_text("Cream")
    expect(page).not_to have_text("Lotion")
    expect(page).not_to have_text("Paste")
    expect(page).not_to have_text("Powder")
  end

  scenario "Searching for a notification by internal reference" do
    visit responsible_person_search_notifications_path(responsible_person.id)
    expect(page).to have_h1("Product – search")

    fill_in "notification_search_form[q]", with: "blend40"
    click_button "Search"

    expect(page).to have_h1("Product – search results")
    expect(page).not_to have_text("Cream")
    expect(page).not_to have_text("Lotion")
    expect(page).to have_text("Paste")
    expect(page).not_to have_text("Powder")
  end

  scenario "Searching for an archived notification" do
    visit responsible_person_search_notifications_path(responsible_person.id)
    expect(page).to have_h1("Product – search")

    fill_in "notification_search_form[q]", with: "Powder"
    click_button "Search"

    expect(page).to have_h1("Product – search results")
    expect(page).not_to have_text("Cream")
    expect(page).not_to have_text("Lotion")
    expect(page).not_to have_text("Paste")
    expect(page).not_to have_text("Powder")

    visit responsible_person_search_notifications_path(responsible_person.id)

    fill_in "notification_search_form[q]", with: "Powder"
    choose "Archived"
    click_button "Search"

    expect(page).to have_h1("Product – search results")
    expect(page).not_to have_text("Cream")
    expect(page).not_to have_text("Lotion")
    expect(page).not_to have_text("Paste")
    expect(page).to have_text("Powder")
  end

  scenario "Editing your search" do
    visit responsible_person_search_notifications_path(responsible_person.id)

    fill_in "notification_search_form[q]", with: "Cream"
    choose "Archived"
    click_button "Search"
    click_button "Edit your search"

    expect(page).to have_field("notification_search_form[q]", with: "Cream")
    expect(page).to have_checked_field("notification_search_form[status]", with: "archived")
  end

  scenario "Show the total number of results" do
    20.times do |i|
      create(:notification, :registered, :with_component, responsible_person:, notification_complete_at: 5.days.ago, product_name: "Sun Lotion #{i}")
    end
    Notification.import_to_opensearch(force: true)
    responsible_person_search_notifications_path(responsible_person.id)

    click_on "Product - search"
    expect(page).to have_h1("Product – search")
    click_on "Search"
    expect(page).to have_text("23 notifications using the current filters were found.")
    expect(page).to have_link("View Sun Lotion 0")
    expect(page).not_to have_link("View Sun Lotion 19")

    click_link("Next page")
    expect(page).to have_text("23 notifications using the current filters were found.")
    expect(page).to have_h1("Product – search results")
    expect(page).not_to have_link("View Sun Lotion 0")
    expect(page).to have_link("View Sun Lotion 19")
  end
end
