require "rails_helper"
require "support/feature_helpers"

RSpec.feature "Search", :with_2fa, :with_2fa_app, :with_stubbed_mailer, :with_stubbed_notify, type: :feature do
  let(:user) { create(:poison_centre_user, :with_sms_secondary_authentication) }
  let(:search_user) { create(:search_user, :with_sms_secondary_authentication) }

  let(:component_a) { create(:component, :using_exact, with_ingredients: %w[aqua tin sodium]) }
  let(:component_b) { create(:component, :using_exact, with_ingredients: %w[aqua tin]) }

  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:another_responsible_person) { create(:responsible_person, :with_a_contact_person) }

  let(:cream) { create(:notification, :registered, components: [component_a], notification_complete_at: 1.day.ago, product_name: "Cream") }
  let(:shower_bubbles) { create(:notification, :registered, responsible_person:, components: [component_b], notification_complete_at: 3.days.ago, product_name: "Shower Bubbles") }

  before do
    configure_requests_for_search_domain
    cream
    shower_bubbles
    Notification.import_to_opensearch(force: true)
  end

  scenario "User without permission is redirected to the poison centre notifications search path" do
    sign_in search_user
    visit poison_centre_ingredients_search_path
    expect(page).to have_current_path(poison_centre_ingredients_search_path)
  end

  scenario "Searching for notifications with specific ingredients" do
    sign_in user
    visit poison_centre_ingredients_search_path

    expect(page).to have_h1("Ingredients search")
    fill_in "ingredient_search_form_q", with: "sodium"
    click_on "Search"

    expect(page).to have_link("Cream")
    expect(page).to have_text("1 notification using the current filters was found.")
    expect(page).not_to have_link("Shower Bubbles")
  end

  scenario "Searching for notifications with specific ingredients - exact match" do
    sign_in user
    visit poison_centre_ingredients_search_path

    expect(page).to have_h1("Ingredients search")
    fill_in "ingredient_search_form_q", with: "tin sodium"
    choose "Exact match only"
    click_on "Search"

    expect(page).to have_link("Cream")
    expect(page).not_to have_link("Shower Bubbles")
  end

  scenario "Searching for notifications with specific ingredients with date filter" do
    sign_in user
    visit poison_centre_ingredients_search_path

    expect(page).to have_h1("Ingredients search")
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
    sign_in user
    visit poison_centre_ingredients_search_path

    expect(page).to have_h1("Ingredients search")
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
    sign_in user
    visit poison_centre_ingredients_search_path

    expect(page).to have_h1("Ingredients search")
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

  scenario "Show the total number of results" do
    sign_in user
    21.times do |i|
      component = create(:component, :using_exact, with_ingredients: %w[stuff])
      create(:notification, :registered, responsible_person:, components: [component], notification_complete_at: 5.days.ago, product_name: "Shower Bubbles #{i}")
    end
    Notification.import_to_opensearch(force: true)

    visit poison_centre_ingredients_search_path
    expect(page).to have_h1("Ingredients search")
    fill_in "ingredient_search_form_q", with: "stuff"
    click_on "Search"
    expect(page).to have_text("21 notifications using the current filters were found.")
    expect(page).to have_link("View Shower Bubbles 0")
    expect(page).not_to have_link("View Shower Bubbles 20")

    click_link("Next page")
    expect(page).to have_text("21 notifications using the current filters were found.")
    expect(page).to have_h1("Ingredient – search results")
    expect(page).not_to have_link("View Shower Bubbles 0")
    expect(page).to have_link("View Shower Bubbles 20")
  end

  scenario "Back link" do
    sign_in user
    visit poison_centre_ingredients_search_path

    expect(page).to have_h1("Ingredients search")
    fill_in "ingredient_search_form_q", with: "aqua"
    click_on "Search"
    click_link "Shower Bubbles"
    click_link "Back"

    expect(page).to have_h1("Ingredient – search results")
  end
end
