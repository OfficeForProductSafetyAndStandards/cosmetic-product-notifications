require "rails_helper"

RSpec.describe "Create multiple responsible person within same keycloak user", type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
    stub_notify_mailer
  end

  scenario "creating another responsible person as a limited company" do
    visit "/responsible_persons/account/overview"
    expect(page).to have_h1("Are you or your organisation a UK Responsible Person?")
    create_another_business_responsible_person
  end

  scenario "Verify dead end page when user choosen as account already exist" do
    visit "/responsible_persons/account/overview"
    expect(page).to have_h1("Are you or your organisation a UK Responsible Person?")
    click_on "Continue"
    expect(page).to have_h1("Does anyone in your organisation have an account to submit cosmetic product notifications in the UK?")
    choose "Yes, I or my organisation have an account"
    click_on "Continue"
    expect(page).to have_h1("To join an existing UK responsible person account, you need to be invited by a team member of that organisation")
  end
end
