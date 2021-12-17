require "rails_helper"

RSpec.describe "Submit notifications", :with_stubbed_antivirus, type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:user) { responsible_person.responsible_person_users.first.user }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  describe "Removing nano material from single item product" do
    scenario "when removing before completing product details" do
      visit "/responsible_persons/#{responsible_person.id}/notifications"

      click_on "Add a cosmetic product"

      complete_product_wizard(name: "Product for nano removal test", nano_materials_count: 2)

      expect_task_not_started "Nanomaterial #1"
      expect_task_not_started "Nanomaterial #2"

      expect_product_details_task_blocked

      click_on "Remove a nanomaterial"

      select_nano_materials_and_remove ["Nanomaterial #1", "Nanomaterial #2"]

      expect_success_banner_with_text "The nanomaterial was deleted from this draft"

      complete_product_details

      expect(page).not_to have_link("Nanomaterial #1")

      expect(page).not_to have_link("Nanomaterial #2")

      click_link "Accept and submit"
      click_button "Accept and submit"

      expect_to_be_on__your_cosmetic_products_page
      expect_to_see_message "Product for nano removal test notification submitted"
    end
  end
end
