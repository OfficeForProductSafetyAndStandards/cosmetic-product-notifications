require "rails_helper"

RSpec.describe "Resposible person creation journey", type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }

  before do
    sign_in as_user: create(:user, first_login: true)
    stub_notify_mailer
  end

   scenario "Given as a new user, I should be able to create responsible user as a individual sole trader" do
    configure_requests_for_submit_domain
	create_individual_responsible_person
	expect(page).to have_h1("Your cosmetic products")
   end


   scenario "Given as a new user, I should be able to create responsible user as a limited company" do
    configure_requests_for_submit_domain
	create_business_responsible_person
	expect(page).to have_h1("Your cosmetic products")
   end

end

