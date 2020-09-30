require "rails_helper"

RSpec.describe "Creating a responsible person", type: :feature do
  context "when logged in as a new user," do
    let(:user) { create(:submit_user, has_accepted_declaration: false) }

    before do
      configure_requests_for_submit_domain
      sign_in user
    end

    scenario "creating a resposible person as a individual sole trader" do
      visit(root_path)

      expect_to_be_on__responsible_person_declaration_page
      click_button "I confirm"

      expect(page).to have_h1("Are you or your organisation a UK Responsible Person?")
      select_options_to_create_account

      select_individual_account_type

      expect(page).to have_h1("UK Responsible Person details")
      fill_in "Name", with: "Auto-test rpuser"
      fill_in_rp_contact_details

      expect(page).to have_h1("Your cosmetic products")
    end

    scenario "creating a responsible person as a limited company" do
      visit(root_path)

      expect_to_be_on__responsible_person_declaration_page
      click_button "I confirm"

      expect(page).to have_h1("Are you or your organisation a UK Responsible Person?")
      select_options_to_create_account

      select_business_account_type

      expect(page).to have_h1("UK Responsible Person details")
      fill_in "Business name", with: "Auto-test rpuser"
      fill_in_rp_contact_details

      expect(page).to have_h1("Your cosmetic products")
    end
  end
end
