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
      create_individual_responsible_person
      expect(page).to have_h1("Your cosmetic products")
    end


    scenario "creating a respoosible person as a limited company" do
      create_business_responsible_person
      expect(page).to have_h1("Your cosmetic products")
    end
  end
end
