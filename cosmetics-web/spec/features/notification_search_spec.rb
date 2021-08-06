require "rails_helper"
require "support/feature_helpers"

RSpec.feature "Creating a Search account from an invitation", :with_stubbed_mailer, :with_stubbed_notify, :with_2fa, :with_2fa_app, type: :feature do
  let(:user) { create(:poison_centre_user, :with_sms_secondary_authentication) }

  let(:cream) { create(:notification, :registered, :with_component, notification_complete_at: 1.day.ago, product_name: "Cream") }
  let(:shower_bubbles) { create(:notification, :registered, :with_component, notification_complete_at: 2.days.ago, product_name: "Shower Bubbles") }
  let(:bath_bubbles) { create(:notification, :registered, :with_component, notification_complete_at: 3.days.ago, product_name: "Bath Bubbles", category: :face_care_products_other_than_face_mask) }

  before do
    configure_requests_for_search_domain

    cream
    shower_bubbles
    bath_bubbles

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

    expect(page).to have_text("1 product matching keyword(s) Bubbles, using the current filters, was found.")

    expect(page).not_to have_link("Cream")
    expect(page).not_to have_link("Shower Bubbles")
    expect(page).to have_link("Bath Bubbles")
  end

  scenario "Sorting search results" do
    sign_in user

    expect(page).to have_h1("Search cosmetic products")

    fill_in "notification_search_form_q", with: "Shower Bubbles"
    click_on "Search"

    links = page.all(".govuk-heading-s .govuk-link").map(&:text)
    expect(links).to eq ["Shower Bubbles", "Bath Bubbles"]

    select "Oldest", from: "Sort by"
    click_on "Sort"

    links = page.all(".govuk-heading-s .govuk-link").map(&:text)

    expect(links).to eq ["Bath Bubbles", "Shower Bubbles"]
  end

  scenario "Searching for notifications with date filter" do
    sign_in user

    expect(page).to have_h1("Search cosmetic products")

    expect(page).to have_link("Cream")
    expect(page).to have_link("Shower Bubbles")
    expect(page).to have_link("Bath Bubbles")

    choose "Date"
    fill_in "notification_search_form_date_exact_day",   with: bath_bubbles.notification_complete_at.day
    fill_in "notification_search_form_date_exact_month", with: bath_bubbles.notification_complete_at.month
    fill_in "notification_search_form_date_exact_year",  with: bath_bubbles.notification_complete_at.year

    click_on "Apply"

    expect(page).to have_text("1 product using the current filters, was found.")

    expect(page).not_to have_link("Cream")
    expect(page).not_to have_link("Shower Bubbles")
    expect(page).to have_link("Bath Bubbles")
  end

  describe "Reference number search" do
    scenario "Searching by whole number" do
      sign_in user

      expect(page).to have_h1("Search cosmetic products")

      expect(page).to have_link("Cream")
      expect(page).to have_link("Shower Bubbles")
      expect(page).to have_link("Bath Bubbles")

      fill_in "notification_search_form_q", with: cream.reference_number

      click_on "Search"

      expect(page).to have_text("1 product matching keyword(s)")

      expect(page).to have_link("Cream")
      expect(page).not_to have_link("Shower Bubbles")
      expect(page).not_to have_link("Bath Bubbles")
    end

    scenario "Searching by partial number number" do
      sign_in user

      expect(page).to have_h1("Search cosmetic products")

      expect(page).to have_link("Cream")
      expect(page).to have_link("Shower Bubbles")
      expect(page).to have_link("Bath Bubbles")

      fill_in "notification_search_form_q", with: cream.reference_number.to_s[0..5]

      click_on "Search"

      expect(page).to have_text("1 product matching keyword(s)")

      expect(page).to have_link("Cream")
      expect(page).not_to have_link("Shower Bubbles")
      expect(page).not_to have_link("Bath Bubbles")
    end

    context "When reference number is small" do
      let(:cream) { create(:notification, :registered, :with_component, notification_complete_at: 1.day.ago, product_name: "Cream", reference_number: 12345) }

      scenario "Searching by partial number number" do
        sign_in user

        expect(page).to have_h1("Search cosmetic products")

        expect(page).to have_link("Cream")
        expect(page).to have_link("Shower Bubbles")
        expect(page).to have_link("Bath Bubbles")

        fill_in "notification_search_form_q", with: cream.reference_number_for_display

        click_on "Search"

        expect(page).to have_text("1 product matching keyword(s)")

        expect(page).to have_link("Cream")
      end
    end
  end
end
