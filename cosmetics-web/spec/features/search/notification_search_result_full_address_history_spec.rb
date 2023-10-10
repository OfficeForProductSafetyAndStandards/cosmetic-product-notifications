require "rails_helper"
require "support/feature_helpers"

RSpec.feature "Search result full address history", :with_stubbed_notify, :with_stubbed_antivirus, :with_2fa, type: :feature do
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person, :with_previous_addresses) }
  let(:nanomaterial_notification) do
    create(:nanomaterial_notification,
           :submitted,
           name: "Zinc oxide",
           responsible_person:,
           submitted_at: Date.new(2022, 1, 1))
  end
  let(:notification) do
    create(:notification,
           :registered,
           notification_complete_at: 1.day.ago,
           product_name: "Cream",
           responsible_person:)
  end
  let(:nano_material) { create(:nano_material_non_standard, nanomaterial_notification:, notification:) }
  let(:component) { create(:ranges_component, :completed, with_nano_materials: [nano_material]) }

  before do
    notification.components << component

    configure_requests_for_search_domain
    Notification.import_to_opensearch(force: true)
    sign_in user
    click_on "Search"
    click_link("View Cream")
  end

  context "with a trading standards user" do
    let(:user) { create(:trading_standards_user, :with_sms_secondary_authentication) }

    scenario "the search result for the notification shows 3 addresses, and a link to view more" do
      expect(page).to have_h1("Cream")
      expect(page).to have_summary_item(key: "Nanomaterials", value: "#{nanomaterial_notification.ukn} - Zinc oxide")
      expect(page).to have_h2("Address history")

      expect(page).to have_selector("a", text: "See full history (5 addresses)")
      click_link("See full history (5 addresses)")

      expect(page).to have_h1("Cream - full address history")
      click_link("Back")
      expect(page).to have_h1("Cream")
      expect(page).to have_summary_item(key: "Nanomaterials", value: "#{nanomaterial_notification.ukn} - Zinc oxide")
      expect(page).to have_h2("Address history")
    end

    context "when the notification has just one previous address" do
      let(:responsible_person) { create(:responsible_person, :with_a_contact_person, :with_a_previous_address) }

      scenario "the search result for the notification shows just the 2 addresses, and no link to view more" do
        expect(page).to have_h1("Cream")
        expect(page).to have_summary_item(key: "Nanomaterials", value: "#{nanomaterial_notification.ukn} - Zinc oxide")
        expect(page).to have_h2("Address history")

        expect(page).not_to have_selector("a", text: "See full history (2 addresses)")
      end
    end
  end

  context "with an opss enforcement user" do
    let(:user) { create(:opss_enforcement_user, :with_sms_secondary_authentication) }

    scenario "the search result for the notification shows 3 addresses, and a link to view more" do
      expect(page).to have_h1("Cream")
      expect(page).to have_summary_item(key: "Nanomaterials", value: "#{nanomaterial_notification.ukn} - Zinc oxide")
      expect(page).to have_h2("Address history")

      expect(page).to have_selector("a", text: "See full history (5 addresses)")
      click_link("See full history (5 addresses)")

      expect(page).to have_h1("Cream - full address history")
      click_link("Back")
      expect(page).to have_h1("Cream")
      expect(page).to have_summary_item(key: "Nanomaterials", value: "#{nanomaterial_notification.ukn} - Zinc oxide")
      expect(page).to have_h2("Address history")
    end

    context "when the notification has just one previous address" do
      let(:responsible_person) { create(:responsible_person, :with_a_contact_person, :with_a_previous_address) }

      scenario "the search result for the notification shows just the 2 addresses, and no link to view more" do
        expect(page).to have_h1("Cream")
        expect(page).to have_summary_item(key: "Nanomaterials", value: "#{nanomaterial_notification.ukn} - Zinc oxide")
        expect(page).to have_h2("Address history")

        expect(page).not_to have_selector("a", text: "See full history (2 addresses)")
      end
    end
  end

  context "with an opss science user" do
    let(:user) { create(:opss_science_user, :with_sms_secondary_authentication) }

    scenario "user cannot see any address history" do
      expect(page).to have_h1("Cream")
      expect(page).not_to have_h2("Address history")
    end
  end

  context "with an opss general user" do
    let(:user) { create(:opss_general_user, :with_sms_secondary_authentication) }

    scenario "user cannot see any address history" do
      expect(page).to have_h1("Cream")
      expect(page).not_to have_h2("Address history")
    end
  end

  context "with a poison centre user" do
    let(:user) { create(:poison_centre_user, :with_sms_secondary_authentication) }

    scenario "user cannot see any address history" do
      expect(page).to have_h1("Cream")
      expect(page).not_to have_h2("Address history")
    end
  end
end
