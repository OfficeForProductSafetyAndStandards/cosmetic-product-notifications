require "rails_helper"
require "support/feature_helpers"

RSpec.feature "Search", :with_stubbed_mailer, :with_stubbed_notify, :with_2fa, :with_2fa_app, type: :feature do
  let(:user) { create(:poison_centre_user, :with_sms_secondary_authentication) }

  let(:component1) { create(:component, with_ingredients: %w[aqua sodium]) }
  let(:component2) { create(:component, with_ingredients: %w[aqua tin]) }

  let(:cream) { create(:notification, :registered, components: [component1], notification_complete_at: 1.day.ago, product_name: "Cream") }
  let(:shower_bubbles) { create(:notification, :registered, components: [component2], notification_complete_at: 2.days.ago, product_name: "Shower Bubbles") }

  before do
    configure_requests_for_search_domain

    cream
    shower_bubbles

    Notification.opensearch.import force: true
  end

  scenario "Searching for notifications with specific ingredients" do
    sign_in user

    expect(page).to have_h1("Cosmetic products search")

    click_link "Ingredients search"

    expect(page).not_to have_link("Cream")
    expect(page).not_to have_link("Shower Bubbles")

    fill_in "ingredient_search_form_q", with: "sodium"
    click_on "Search"

    expect(page).to have_link("Cream")
    expect(page).not_to have_link("Shower Bubbles")
  end
end
