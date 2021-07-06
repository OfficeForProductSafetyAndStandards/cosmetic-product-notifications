require "rails_helper"

RSpec.describe "Creating multiple responsible persons from the same user", type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:user) { responsible_person.responsible_person_users.first.user }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  scenario "creating another responsible person as a limited company" do
    visit "/responsible_persons/account/overview"
    expect(page).to have_h1("Are you or your organisation a UK Responsible Person?")
    # Creating another business responsible person
    select_options_to_create_rp_account
    select_rp_business_account_type
    fill_in_rp_business_details
    fill_in_rp_contact_details
  end

  scenario "Verify dead end page when user choosen as account already exist" do
    visit "/responsible_persons/account/overview"
    expect(page).to have_h1("Are you or your organisation a UK Responsible Person?")
    click_on "Continue"
    expect(page).to have_h1("Has your Responsible Person account already been set up?")
    choose "Yes, I or my organisation have an account"
    click_on "Continue"
    expect(page).to have_h1("To join an existing UK Responsible Person account, you need to be invited by a team member of that organisation")
  end
end
