require "rails_helper"
require "support/feature_helpers"

RSpec.feature "Creating a Search account from an invitation", :with_stubbed_mailer, :with_stubbed_notify, :with_2fa, :with_2fa_app, type: :feature do
  let(:user) { create(:poison_centre_user, :with_sms_secondary_authentication) }

  let(:notification1) { create(:notification, :registered, :with_component, notification_complete_at: 1.day.ago, product_name: "Cream") }
  let(:notification2) { create(:notification, :registered, :with_component, notification_complete_at: 2.days.ago, product_name: "Shower Bubbles") }
  let(:notification3) { create(:notification, :registered, :with_component, notification_complete_at: 3.days.ago, product_name: "Bath Bubbles", category: :face_care_products_other_than_face_mask) }

  before do
    configure_requests_for_search_domain
    notification1
    notification2
    notification3

    Notification.elasticsearch.import force: true
  end

  scenario "Searching for notifications" do
    sign_in user

    expect(page).to have_h1("Search cosmetic products")

    expect(page).to have_link("Cream")
    expect(page).to have_link("Shower Bubbles")
    expect(page).to have_link("Bath Bubbles")

    fill_in "notification_search_form_q", with: "Bubbles"
    click_on "Search"

    expect(page).not_to have_link("Cream")

    expect(page).to have_link("Shower Bubbles")
    expect(page).to have_link("Bath Bubbles")

    select "Skin products", from: "Product category"
    click_on "Apply"

    expect(page).to have_text("1 product matching keyword(s) Bubbles, were found.")

    expect(page).not_to have_link("Cream")
    expect(page).not_to have_link("Shower Bubbles")
    expect(page).to have_link("Bath Bubbles")
  end

  scenario "Searching for notifications with date filter" do
    sign_in user

    expect(page).to have_h1("Search cosmetic products")

    expect(page).to have_link("Cream")
    expect(page).to have_link("Shower Bubbles")
    expect(page).to have_link("Bath Bubbles")

    fill_in "notification_search_form_q", with: "Bubbles"
    choose "Date"
    fill_in "notification_search_form_date_exact_day",   with: notification3.notification_complete_at.day
    fill_in "notification_search_form_date_exact_month", with: notification3.notification_complete_at.month
    fill_in "notification_search_form_date_exact_year",  with: notification3.notification_complete_at.year

    click_on "Search"

    select "Skin products", from: "Product category"
    click_on "Apply"

    expect(page).not_to have_link("Cream")
    expect(page).not_to have_link("Shower Bubbles")
    expect(page).to have_link("Bath Bubbles")
  end
end
