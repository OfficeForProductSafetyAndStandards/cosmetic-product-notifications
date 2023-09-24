require "rails_helper"
require "support/feature_helpers"

RSpec.feature "Search result", :with_stubbed_notify, :with_stubbed_antivirus, :with_2fa, type: :feature do
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
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
  end

  context "with an opss science user" do
    let(:user) { create(:opss_science_user, :with_sms_secondary_authentication) }

    scenario "user can see the nanomaterial details with review period section and link to nanomaterial pdf file" do
      expect(page).to have_h1("Cosmetic products search")
      click_on "Search"
      click_link("View Cream")

      expect(page).to have_h1("Cream")
      within(:css, "#item-1") do
        expect(page).to have_summary_item(key: "Nanomaterials", value: "#{nanomaterial_notification.ukn} - Zinc oxide testPdf.pdf (PDF, 11.6 KB)")
        expect(page).to have_summary_item(
          key: "Nanomaterials review period end date",
          value: "#{nanomaterial_notification.ukn} - Zinc oxide - 1 July 2022",
        )
      end
    end
  end

  context "with an opss general user" do
    let(:user) { create(:opss_general_user, :with_sms_secondary_authentication) }

    scenario "user can see the nanomaterial details with review period section but without link to nanomaterial pdf file" do
      expect(page).to have_h1("Cosmetic products search")
      click_on "Search"
      click_link("View Cream")

      expect(page).to have_h1("Cream")
      expect(page).to have_summary_item(key: "Nanomaterials", value: "#{nanomaterial_notification.ukn} - Zinc oxide")
      expect(page).to have_summary_item(
        key: "Nanomaterials review period end date",
        value: "#{nanomaterial_notification.ukn} - Zinc oxide - 1 July 2022",
      )
    end
  end

  context "with an opss enforcement user" do
    let(:user) { create(:opss_enforcement_user, :with_sms_secondary_authentication) }

    scenario "user can see the nanomaterial details with review period section but without link to nanomaterial pdf file" do
      expect(page).to have_h1("Cosmetic products search")
      click_on "Search"
      click_link("View Cream")

      expect(page).to have_h1("Cream")
      expect(page).to have_summary_item(key: "Nanomaterials", value: "#{nanomaterial_notification.ukn} - Zinc oxide")
      expect(page).to have_summary_item(
        key: "Nanomaterials review period end date",
        value: "#{nanomaterial_notification.ukn} - Zinc oxide - 1 July 2022",
      )
    end
  end

  context "with an opss imt user" do
    let(:user) { create(:opss_imt_user, :with_sms_secondary_authentication) }

    scenario "user can see the nanomaterial details with review period section but without link to nanomaterial pdf file" do
      expect(page).to have_h1("Cosmetic products search")
      click_on "Search"
      click_link("View Cream")

      expect(page).to have_h1("Cream")
      expect(page).to have_summary_item(key: "Nanomaterials", value: "#{nanomaterial_notification.ukn} - Zinc oxide")
      expect(page).to have_summary_item(
        key: "Nanomaterials review period end date",
        value: "#{nanomaterial_notification.ukn} - Zinc oxide - 1 July 2022",
      )
    end
  end

  context "with a trading standards user" do
    let(:user) { create(:trading_standards_user, :with_sms_secondary_authentication) }

    scenario "user can see the nanomaterial details with review period section but without link to nanomaterial pdf file" do
      expect(page).to have_h1("Cosmetic products search")
      click_on "Search"
      click_link("View Cream")

      expect(page).to have_h1("Cream")
      expect(page).to have_summary_item(key: "Nanomaterials", value: "#{nanomaterial_notification.ukn} - Zinc oxide")
      expect(page).to have_summary_item(
        key: "Nanomaterials review period end date",
        value: "#{nanomaterial_notification.ukn} - Zinc oxide - 1 July 2022",
      )
    end
  end

  context "with a poison centre user" do
    let(:user) { create(:poison_centre_user, :with_sms_secondary_authentication) }

    scenario "user can see the nanomaterial details but without review period section or link to nanomaterial pdf file" do
      expect(page).to have_h1("Cosmetic products search")
      click_on "Search"
      click_link("View Cream")

      expect(page).to have_h1("Cream")
      within(:css, "#item-1") do
        expect(page).to have_summary_item(key: "Nanomaterials", value: "#{nanomaterial_notification.ukn} - Zinc oxide")
        expect(page).not_to have_summary_item(
          key: "Nanomaterials review period end date",
          value: "#{nanomaterial_notification.ukn} - Zinc oxide - 1 July 2022",
        )
      end
    end
  end
end
