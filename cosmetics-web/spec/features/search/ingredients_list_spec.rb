require "rails_helper"
require "support/feature_helpers"

RSpec.feature "Ingredients list", :with_stubbed_mailer, :with_stubbed_notify, :with_2fa, :with_2fa_app, type: :feature do
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

    click_link "Ingredients list"

    expect(page).to have_link("aqua")
    expect(page).to have_link("tin")
    expect(page).to have_link("sodium")

    click_link "sodium"

    expect(page).to have_link(cream.responsible_person.name)
    expect(page).not_to have_link(responsible_person.name)

    click_link cream.responsible_person.name

    expect(page).to have_link("Cream")
    expect(page).not_to have_link("Shower Bubbles")
  end
end
