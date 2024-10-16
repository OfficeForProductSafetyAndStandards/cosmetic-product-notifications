require "rails_helper"
require "support/feature_helpers"

RSpec.feature "Manage cosmetic notifications", :with_2fa, :with_2fa_app, :with_stubbed_mailer, :with_stubbed_notify, type: :feature do
  let(:user) { create(:support_user, :with_sms_secondary_authentication) }
  let(:notification_a) { create(:registered_notification, product_name: "Calendula") }
  let(:notification_b) { create(:registered_notification, product_name: "Calendula soap") }
  let(:notification_c) { create(:registered_notification, product_name: "Tea tree oil") }
  let(:archived_notification) { create(:archived_notification, product_name: "Apple and calendula hand wash") }

  before do
    configure_requests_for_support_domain

    notification_a
    notification_b
    notification_c
    archived_notification

    sign_in user
  end

  scenario "Searching for notifications using a search term" do
    expect(page).to have_h1("Dashboard")

    click_link "Manage cosmetic notifications"

    expect(page).to have_h1("Search for cosmetic product notifications")

    fill_in "Enter a search term", with: "calendula"
    click_on "Search", match: :first

    expect(page).to have_text(notification_a.product_name)
    expect(page).to have_text(notification_b.product_name)
    expect(page).to have_text(archived_notification.product_name)
    expect(page).not_to have_text(notification_c.product_name)
  end

  scenario "Searching for notifications using a search term with no results" do
    expect(page).to have_h1("Dashboard")

    click_link "Manage cosmetic notifications"

    expect(page).to have_h1("Search for cosmetic product notifications")

    fill_in "Enter a search term", with: "lavender"
    click_on "Search", match: :first

    expect(page).to have_text("There are no cosmetic product notifications for your search.")

    click_on "Clear search results"

    expect(page).to have_text("Enter a search term")
  end

  scenario "Searching for notifications using a search term and filtering by status" do
    expect(page).to have_h1("Dashboard")

    click_link "Manage cosmetic notifications"

    expect(page).to have_h1("Search for cosmetic product notifications")

    fill_in "Enter a search term", with: "calendula"
    check "Archived"
    click_on "Search", match: :first

    expect(page).to have_text(archived_notification.product_name)
    expect(page).not_to have_text(notification_a.product_name)
    expect(page).not_to have_text(notification_b.product_name)
    expect(page).not_to have_text(notification_c.product_name)
  end

  scenario "Searching for notifications using a search term and filtering by date" do
    expect(page).to have_h1("Dashboard")

    click_link "Manage cosmetic notifications"

    expect(page).to have_h1("Search for cosmetic product notifications")

    fill_in "Enter a search term", with: "calendula"
    fill_in "notification_search_date_from_3i", with: 1
    fill_in "notification_search_date_from_2i", with: 1
    fill_in "notification_search_date_from_1i", with: 2000
    fill_in "notification_search_date_to_3i", with: 1
    fill_in "notification_search_date_to_2i", with: 1
    fill_in "notification_search_date_to_1i", with: 2020
    click_on "Search", match: :first

    expect(page).to have_text("There are no cosmetic product notifications for your search.")
  end

  scenario "Searching for notifications using a search term and filtering by only one date" do
    expect(page).to have_h1("Dashboard")

    click_link "Manage cosmetic notifications"

    expect(page).to have_h1("Search for cosmetic product notifications")

    fill_in "Enter a search term", with: "calendula"
    fill_in "notification_search_date_from_3i", with: 1
    fill_in "notification_search_date_from_2i", with: 1
    fill_in "notification_search_date_from_1i", with: 2000
    click_on "Search", match: :first

    expect(page).to have_text("Error: To date cannot be blank")
  end

  scenario "Searching for notifications using a UKCP number" do
    expect(page).to have_h1("Dashboard")

    click_link "Manage cosmetic notifications"

    expect(page).to have_h1("Search for cosmetic product notifications")

    fill_in "Enter a search term", with: notification_b.reference_number
    click_on "Search", match: :first

    expect(page).to have_text(notification_b.reference_number)
    expect(page).not_to have_text(notification_a.reference_number)
    expect(page).not_to have_text(notification_c.reference_number)
    expect(page).not_to have_text(archived_notification.reference_number)
  end

  scenario "Searching for an empty string" do
    expect(page).to have_h1("Dashboard")

    click_link "Manage cosmetic notifications"

    expect(page).to have_h1("Search for cosmetic product notifications")

    click_on "Search", match: :first

    expect(page).to have_text(notification_a.reference_number)
    expect(page).to have_text(notification_b.reference_number)
    expect(page).to have_text(notification_c.reference_number)
    expect(page).to have_text(archived_notification.reference_number)
  end

  scenario "Viewing a notification" do
    visit "/notifications/#{notification_b.reference_number}"

    expect(page).to have_h1(notification_b.product_name)

    expect(page).to have_text(notification_b.reference_number)
  end

  scenario "Viewing an archived notification" do
    visit "/notifications/#{archived_notification.reference_number}"

    expect(page).to have_h1("#{archived_notification.product_name} Archived")

    expect(page).to have_text(archived_notification.reference_number)
  end

  scenario "Deleting and recovering a notification" do
    visit "/notifications/#{notification_a.reference_number}"

    expect(page).to have_h1(notification_a.product_name)

    click_button "Delete this notification"

    expect(page).to have_h1("#{notification_a.product_name} Deleted")

    click_button "Recover this notification"

    expect(page).to have_h1(notification_a.product_name)
  end
end
