require "rails_helper"

RSpec.describe "Notifications Dashboard", :with_stubbed_antivirus, type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  describe "notification with frame formulation and poisonous ingredient" do
    # frame formulation, with poisonous ingredient
    let(:notification) do
      create(:registered_notification, components: [component], responsible_person:)
    end

    context "when formulation file is not present" do
      let(:component) { create(:predefined_component, :completed, :with_poisonous_ingredients) }

      it "does not display ingredients informations" do
        visit responsible_person_notification_path(responsible_person, notification)

        expect(page).not_to have_summary_item(key: "Ingredients NPIS needs to know about", value: nil)
      end
    end

    context "when formulation file is present" do
      let(:component) { create(:predefined_component, :completed, :with_poisonous_ingredients, :with_formulation_file) }

      it "does not display ingredients informations" do
        visit responsible_person_notification_path(responsible_person, notification)

        expect(page).to have_summary_item(key: "Ingredients NPIS needs to know about", value: "testPdf.pdf (PDF, 11.6 KB)")
      end
    end
  end

  describe "Displaying acute poisonous information" do
    let(:notification) do
      create(:registered_notification, components: [component], responsible_person:)
    end

    context "when is present" do
      let(:component) { create(:predefined_component, :completed, :with_poisonous_ingredients, acute_poisoning_info: "Toxins") }

      it "is displayed" do
        visit responsible_person_notification_path(responsible_person, notification)

        expect(page).to have_summary_item(key: "Acute poisoning information", value: "Toxins")
      end
    end

    context "when is not present" do
      let(:component) { create(:predefined_component, :completed, :with_poisonous_ingredients) }

      it "is not displayed" do
        visit responsible_person_notification_path(responsible_person, notification)

        expect(page).not_to have_summary_item(key: "Acute poisoning information", value: "Toxins")
      end
    end
  end
end
