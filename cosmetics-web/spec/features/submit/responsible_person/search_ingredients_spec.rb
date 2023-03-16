require "rails_helper"
require "support/feature_helpers"

RSpec.describe "Search ingredients page", type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:submit_user) { responsible_person.responsible_person_users.first.user }

  let(:component1) { create(:component, :using_exact, with_ingredients: %w[aqua]) }
  let(:component2) { create(:component, :using_exact, with_ingredients: %w[sodium]) }

  let(:cream) { create(:notification, :registered, components: [component1], notification_complete_at: 1.day.ago, product_name: "Cream", responsible_person:) }
  let(:lotion) { create(:notification, :registered, components: [component2], notification_complete_at: 1.day.ago, product_name: "Lotion", responsible_person:) }

  before do
    configure_requests_for_submit_domain
    cream
    lotion
    Notification.import_to_opensearch(force: true)
    sign_in_as_member_of_responsible_person(responsible_person, submit_user)
  end

  scenario "searching for a ingredient by name" do
    visit responsible_person_search_ingredients_path(responsible_person.id)
    expect(page).to have_h1("Ingredient – search")

    fill_in "ingredient_search_form[q]", with: "aqua"
    click_button "Search"

    expect(page).to have_h1("Ingredient – search results")
    expect(page).to have_text("Cream")
    expect(page).not_to have_text("Lotion")
  end

  scenario "show the total number of results" do
    21.times do |i|
      component = create(:component, :using_exact, with_ingredients: %w[stuff])
      create(:notification, :registered, responsible_person:, components: [component], notification_complete_at: 5.days.ago, product_name: "Shower Bubbles #{i}")
    end
    Notification.import_to_opensearch(force: true)

    visit responsible_person_search_ingredients_path(responsible_person.id)
    expect(page).to have_h1("Ingredient – search")
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


  scenario "Editing your search" do
    visit responsible_person_search_ingredients_path(responsible_person.id)

    fill_in "ingredient_search_form[q]", with: "Cream"
    click_button "Search"
    click_button "Edit your search"

    expect(page).to have_field("ingredient_search_form[q]", with: "Cream")
  end
end
