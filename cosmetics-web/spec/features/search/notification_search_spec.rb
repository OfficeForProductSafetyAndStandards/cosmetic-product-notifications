require "rails_helper"
require "support/feature_helpers"

RSpec.feature "Search", :with_stubbed_mailer, :with_stubbed_notify, :with_2fa, :with_2fa_app, type: :feature do
  let(:user) { create(:opss_science_user, :with_sms_secondary_authentication) }

  let(:responsible_person_name) { "Responsible Person" }

  let(:responsible_person) { create(:responsible_person, name: responsible_person_name) }
  let(:other_responsible_person) { create(:responsible_person, :with_a_contact_person) }

  let(:cream) { create(:notification, :registered, :with_component, notification_complete_at: 1.day.ago, product_name: "Cream", responsible_person:) }
  let(:shower_bubbles) { create(:notification, :registered, :with_component, notification_complete_at: 2.days.ago, product_name: "Shower Bubbles", responsible_person: other_responsible_person) }
  let(:bath_bubbles) { create(:notification, :registered, :with_component, notification_complete_at: 3.days.ago, product_name: "Bath Bubbles", category: :face_care_products_other_than_face_mask) }

  before do
    configure_requests_for_search_domain

    cream
    shower_bubbles
    bath_bubbles

    Notification.opensearch.import force: true

    sign_in user
  end

  scenario "Searching for notifications" do
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

    expect(page).to have_text("1 notification matching keyword(s) Bubbles, using the current filters, was found.")

    expect(page).not_to have_link("Cream")
    expect(page).not_to have_link("Shower Bubbles")
    expect(page).to have_link("Bath Bubbles")
  end

  scenario "Sorting search results" do
    expect(page).to have_h1("Search cosmetic products")

    fill_in "notification_search_form_q", with: "Bubbles"
    click_on "Search"

    links = page.all("table#table-items .govuk-link").map(&:text)
    expect(links).to eq ["Shower Bubbles", "Bath Bubbles"]

    select "Oldest", from: "Sort by"
    click_on "Sort"

    links = page.all("table#table-items .govuk-link").map(&:text)

    expect(links).to eq ["Bath Bubbles", "Shower Bubbles"]
  end

  scenario "Searching for notifications with date filter" do
    expect(page).to have_h1("Search cosmetic products")

    expect(page).to have_link("Cream")
    expect(page).to have_link("Shower Bubbles")
    expect(page).to have_link("Bath Bubbles")

    choose "Date"
    fill_in "date_exact_day",   with: bath_bubbles.notification_complete_at.day
    fill_in "date_exact_month", with: bath_bubbles.notification_complete_at.month
    fill_in "date_exact_year",  with: bath_bubbles.notification_complete_at.year

    click_on "Apply"

    expect(page).to have_text("1 notification using the current filters, was found.")

    expect(page).not_to have_link("Cream")
    expect(page).not_to have_link("Shower Bubbles")
    expect(page).to have_link("Bath Bubbles")
  end

  describe "Reference number search" do
    scenario "Searching by whole number" do
      expect(page).to have_h1("Search cosmetic products")

      expect(page).to have_link("Cream")
      expect(page).to have_link("Shower Bubbles")
      expect(page).to have_link("Bath Bubbles")

      fill_in "notification_search_form_q", with: cream.reference_number

      click_on "Search"

      expect(page).to have_text("1 notification matching keyword(s)")

      expect(page).to have_link("Cream")
      expect(page).not_to have_link("Shower Bubbles")
      expect(page).not_to have_link("Bath Bubbles")
    end

    scenario "Searching by partial number" do
      expect(page).to have_h1("Search cosmetic products")

      expect(page).to have_link("Cream")
      expect(page).to have_link("Shower Bubbles")
      expect(page).to have_link("Bath Bubbles")

      fill_in "notification_search_form_q", with: cream.reference_number.to_s[0..5]

      click_on "Search"

      expect(page).to have_text("0 notifications matching keyword(s)")

      expect(page).not_to have_link("Cream")
      expect(page).not_to have_link("Shower Bubbles")
      expect(page).not_to have_link("Bath Bubbles")
    end

    context "when reference number is small" do
      let(:cream) { create(:notification, :registered, :with_component, notification_complete_at: 1.day.ago, product_name: "Cream", reference_number: 12_345) }

      scenario "Searching by partial number" do
        expect(page).to have_h1("Search cosmetic products")

        expect(page).to have_link("Cream")
        expect(page).to have_link("Shower Bubbles")
        expect(page).to have_link("Bath Bubbles")

        fill_in "notification_search_form_q", with: cream.reference_number_for_display

        click_on "Search"

        expect(page).to have_text("1 notification matching keyword(s)")

        expect(page).to have_link("Cream")
      end
    end
  end

  scenario "Does not display pagination until has more than 20 results" do
    17.times do |i|
      create(:notification, :registered, :with_component, notification_complete_at: 5.days.ago, product_name: "Sun Lotion #{i}")
    end
    Notification.opensearch.import force: true

    visit "/notifications"

    expect(page).to have_h1("Search cosmetic products")
    expect(page).to have_link("Cream")
    expect(page).to have_link("Shower Bubbles")
    expect(page).to have_link("Bath Bubbles")
    17.times do |i|
      expect(page).to have_link("Sun Lotion #{i}")
    end

    expect(page).not_to have_text("Page 1")
    expect(page).not_to have_link("Next page")

    # With 21 results, we should see the pagination
    create(:notification, :registered, :with_component, notification_complete_at: 5.days.ago, product_name: "Sun Lotion 17")
    Notification.opensearch.import force: true

    visit "/notifications"

    expect(page).to have_h1("Search cosmetic products")
    expect(page).to have_link("Cream")
    expect(page).to have_link("Shower Bubbles")
    expect(page).to have_link("Bath Bubbles")
    (1..16).each do |i|
      expect(page).to have_link("Sun Lotion #{i}")
    end
    expect(page).not_to have_link("Sun Lotion 0")
    expect(page).to have_text("Page 1")
    expect(page).to have_link("Next page")

    click_link("Next page")
    expect(page).to have_h1("Search cosmetic products")
    expect(page).to have_link("Sun Lotion 0")
    expect(page).to have_text("Page 2")
    expect(page).to have_link("Previous page")
  end

  scenario "Back link" do
    expect(page).to have_h1("Search cosmetic products")

    click_link "Shower Bubbles"

    click_link "Back"

    expect(page).to have_h1("Search cosmetic products")
  end

  context "when using advanced search" do
    scenario "Searching by partial number number" do
      expect(page).to have_h1("Search cosmetic products")

      expect(page).to have_link("Cream")
      expect(page).to have_link("Shower Bubbles")
      expect(page).to have_link("Bath Bubbles")

      fill_in "notification_search_form_q", with: cream.reference_number.to_s[0..5]

      click_on "Search"

      check "Include similar words"

      click_on "Search"

      expect(page).to have_text("1 notification matching keyword(s)")

      expect(page).to have_link("Cream")
      expect(page).not_to have_link("Shower Bubbles")
      expect(page).not_to have_link("Bath Bubbles")
    end

    context "when choosing fields to search" do
      let(:responsible_person_name) { "Bubbles RP" }

      scenario "Searching for notifications" do
        expect(page).to have_h1("Search cosmetic products")

        fill_in "notification_search_form_q", with: "Bubbles"
        click_on "Search"

        expect(page).to have_link("Cream")

        expect(page).to have_link("Shower Bubbles")
        expect(page).to have_link("Bath Bubbles")

        choose "Notification name"
        click_on "Search"

        expect(page).not_to have_link("Cream")
        expect(page).to have_link("Shower Bubbles")
        expect(page).to have_link("Bath Bubbles")

        choose "Responsible Person name&sol;address"
        click_on "Search"

        expect(page).to have_link("Cream")
        expect(page).not_to have_link("Shower Bubbles")
        expect(page).not_to have_link("Bath Bubbles")
      end
    end
  end
end