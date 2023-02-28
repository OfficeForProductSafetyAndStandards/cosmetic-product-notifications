require "rails_helper"
require "support/feature_helpers"

RSpec.feature "Search", :with_stubbed_mailer, :with_stubbed_notify, :with_2fa, :with_2fa_app, type: :feature do
  let(:user) { create(:poison_centre_user, :with_sms_secondary_authentication) }

  let(:component1) { create(:component, :using_exact, with_ingredients: %w[aqua tin sodium]) }
  let(:component2) { create(:component, :using_exact, with_ingredients: %w[aqua tin]) }

  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }

  let(:cream) { create(:notification, :registered, components: [component1], notification_complete_at: 1.day.ago, product_name: "Cream") }
  let(:shower_bubbles) { create(:notification, :registered, responsible_person:, components: [component2], notification_complete_at: 3.days.ago, product_name: "Shower Bubbles") }

  before do
    configure_requests_for_search_domain

    cream
    shower_bubbles

    Notification.import_to_opensearch(force: true)

    sign_in user
  end

  scenario "Searching for notifications with specific ingredients" do
    expect(page).to have_h1("Search cosmetic products")

    click_link "Ingredients search"

    expect(page).not_to have_link("Cream")
    expect(page).not_to have_link("Shower Bubbles")

    fill_in "ingredient_search_form_q", with: "sodium"
    click_on "Search"

    expect(page).to have_link("Cream")
    expect(page).to have_text("Ingredient matches: sodium")
    expect(page).not_to have_link("Shower Bubbles")
  end

  scenario "Searching for notifications with specific ingredients - exact match" do
    expect(page).to have_h1("Search cosmetic products")

    click_link "Ingredients search"

    fill_in "ingredient_search_form_q", with: "tin sodium"
    click_on "Search"
    choose "Exact match only"
    click_on "Apply"

    expect(page).to have_link("Cream")
    expect(page).not_to have_link("Shower Bubbles")
  end

  scenario "Searching for notifications with specific ingredients with date filter" do
    expect(page).to have_h1("Search cosmetic products")

    click_link "Ingredients search"

    expect(page).not_to have_link("Cream")
    expect(page).not_to have_link("Shower Bubbles")

    fill_in "ingredient_search_form_q", with: "aqua"
    click_on "Search"

    fill_in "date_from_day",   with: shower_bubbles.notification_complete_at.day
    fill_in "date_from_month", with: shower_bubbles.notification_complete_at.month
    fill_in "date_from_year",  with: shower_bubbles.notification_complete_at.year

    fill_in "date_to_day",   with: shower_bubbles.notification_complete_at.day
    fill_in "date_to_month", with: shower_bubbles.notification_complete_at.month
    fill_in "date_to_year",  with: shower_bubbles.notification_complete_at.year

    click_on "Apply"

    expect(page).not_to have_link("Cream")
    expect(page).to have_link("Shower Bubbles")
  end

  scenario "Sorting search results" do
    expect(page).to have_h1("Search cosmetic products")

    click_link "Ingredients search"

    fill_in "ingredient_search_form_q", with: "tin"
    click_on "Search"

    links = page.all("table#table-items .govuk-link").map(&:text)
    expect(links).to eq ["Shower Bubbles", "Cream"]

    select "Newest", from: "Sort by"
    click_on "Sort"

    links = page.all("table#table-items .govuk-link").map(&:text)

    expect(links).to eq ["Cream", "Shower Bubbles"]
  end

  scenario "Back link" do
    expect(page).to have_h1("Search cosmetic products")

    click_link "Ingredients search"

    fill_in "ingredient_search_form_q", with: "aqua"
    click_on "Search"

    click_link "Shower Bubbles"

    click_link "Back"

    expect(page).to have_h1("Ingredients search")
  end
end
