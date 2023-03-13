require "rails_helper"
require "support/feature_helpers"

RSpec.feature "Search", :with_stubbed_mailer, :with_stubbed_notify, :with_2fa, :with_2fa_app, type: :feature do
  let(:user) { create(:poison_centre_user, :with_sms_secondary_authentication) }

  let(:component1) { create(:component, :using_exact, with_ingredients: %w[aqua tin sodium]) }
  let(:component2) { create(:component, :using_exact, with_ingredients: %w[aqua tin]) }

  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:responsible_person2) { create(:responsible_person, :with_a_contact_person) }

  let(:cream) { create(:notification, :registered, components: [component1], notification_complete_at: 1.day.ago, product_name: "Cream") }
  let(:shower_bubbles) { create(:notification, :registered, responsible_person:, components: [component2], notification_complete_at: 3.days.ago, product_name: "Shower Bubbles") }
  let(:shower_bubbles2) { create(:notification, :registered, responsible_person2:, components: [component2], notification_complete_at: 5.days.ago, product_name: "Shower Bubbles 2") }

  before do
    configure_requests_for_search_domain

    cream
    shower_bubbles

    Notification.import_to_opensearch(force: true)

    sign_in user
  end

  scenario "Searching for notifications with specific ingredients" do
    expect(page).to have_h1("Cosmetic products search")

    click_link "Ingredients search"

    expect(page).not_to have_link("Cream")
    expect(page).not_to have_link("Shower Bubbles")

    fill_in "ingredient_search_form_q", with: "sodium"
    click_on "Search"

    expect(page).to have_link("Cream")
    expect(page).to have_text("1 notification using the current filters was found.")
    expect(page).not_to have_link("Shower Bubbles")
  end

  scenario "Searching for notifications with specific ingredients - exact match" do
    expect(page).to have_h1("Cosmetic products search")

    click_link "Ingredients search"

    fill_in "ingredient_search_form_q", with: "tin sodium"

    choose "Exact match only"
    click_on "Search"

    expect(page).to have_link("Cream")
    expect(page).not_to have_link("Shower Bubbles")
  end

  scenario "Searching for notifications with specific ingredients with date filter" do
    expect(page).to have_h1("Cosmetic products search")

    click_link "Ingredients search"

    expect(page).not_to have_link("Cream")
    expect(page).not_to have_link("Shower Bubbles")

    fill_in "ingredient_search_form_q", with: "aqua"

    fill_in "date_from_day",   with: shower_bubbles.notification_complete_at.day
    fill_in "date_from_month", with: shower_bubbles.notification_complete_at.month
    fill_in "date_from_year",  with: shower_bubbles.notification_complete_at.year

    fill_in "date_to_day",   with: shower_bubbles.notification_complete_at.day
    fill_in "date_to_month", with: shower_bubbles.notification_complete_at.month
    fill_in "date_to_year",  with: shower_bubbles.notification_complete_at.year

    click_on "Search"

    expect(page).not_to have_link("Cream")
    expect(page).to have_link("Shower Bubbles")
  end

  scenario "Sorting search results" do
    expect(page).to have_h1("Cosmetic products search")

    click_link "Ingredients search"

    fill_in "ingredient_search_form_q", with: "tin"
    click_on "Search"

    links = page.all("table#table-items .govuk-link").map(&:text)
    expect(links).to eq ["View Shower Bubbles", "View Cream"]

    click_on "Edit your search"

    choose "Newest"
    click_on "Search"

    links = page.all("table#table-items .govuk-link").map(&:text)

    expect(links).to eq ["View Cream", "View Shower Bubbles"]
  end

  scenario "Grouping search results" do
    expect(page).to have_h1("Cosmetic products search")

    click_link "Ingredients search"

    fill_in "ingredient_search_form_q", with: "tin"
    click_on "Search"

    links = page.all("table#table-items .govuk-link").map(&:text)
    expect(links).to eq ["View Shower Bubbles", "View Cream"]

    click_on "Edit your search"
    choose "Responsible Person"
    click_on "Search"

    links = page.all("table#table-items .govuk-link").map(&:text)
    expect(links).to eq ["View Cream", "View Shower Bubbles"]
  end

  scenario "Back link" do
    expect(page).to have_h1("Cosmetic products search")

    click_link "Ingredients search"

    fill_in "ingredient_search_form_q", with: "aqua"
    click_on "Search"

    click_link "Shower Bubbles"

    click_link "Back"

    expect(page).to have_h1("Ingredients search")
  end
end
