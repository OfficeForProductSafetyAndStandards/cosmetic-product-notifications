require "rails_helper"

RSpec.describe "Responsible person creation journey", type: :feature do
  context "when logged in as a new user," do
    let(:user) { create(:user, first_login: true) }

    before do
      sign_in as_user: user
      stub_notify_mailer
      configure_requests_for_submit_domain
    end

    scenario "creating a resposible person as a individual sole trader" do
      visit(root_path)
      expect(page).to have_h1("Responsible Person Declaration")
      click_button "I confirm"
      expect(page).to have_h1("Are you or your organisation a UK Responsible Person?")
      select_options_to_create_account
      select_individual_account_type
      expect(page).to have_h1("UK Responsible Person details")
      fill_in "Name", with: "Auto-test rpuser"
      fill_in_rp_contact_details
      expect(page).to have_h1("Your cosmetic products")
    end

    scenario "creating a respoosible person as a limited company" do
      visit(root_path)
      expect(page).to have_h1("Responsible Person Declaration")
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
