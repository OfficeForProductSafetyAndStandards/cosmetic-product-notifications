require "rails_helper"

RSpec.describe "Creating multiple responsible persons from the same user", type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person, name: "First RP") }
  let(:user) { responsible_person.responsible_person_users.first.user }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  scenario "creating another responsible person as a limited company from fresh session" do
    visit "/responsible_persons/account/overview"
    expect(page).to have_h1("Are you or your organisation a UK Responsible Person?")
    # Creating another business responsible person
    select_options_to_create_rp_account
    fill_in_rp_business_details(name: "Second RP")
    fill_in_rp_contact_details

    expect(page).to have_text("The new Responsible Person has been added to your list of Responsible Persons and can be selected as the Responsible Person.")
    expect(page).to have_text("First RP")
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
