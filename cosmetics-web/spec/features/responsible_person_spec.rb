require "rails_helper"

RSpec.describe "Creating multiple responsible persons from the same user", type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person, name: "First RP") }
  let(:responsible_person2) { create(:responsible_person, :with_a_contact_person, name: "Second RP") }
  let(:user) { responsible_person.responsible_person_users.first.user }

  before do
    create(:responsible_person_user, user:, responsible_person: responsible_person2)

    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  scenario "Changing responsible person" do
    visit "/"

    choose "First RP"
    click_button "Save and continue"

    expect(page).not_to have_text("Responsible Person was changed")
    visit "/"
    click_on "Your cosmetic products"
    click_link "Responsible Person"
    expect(page).to have_css("dd", text: "First RP")
    click_link "Change the Responsible Person"
    choose "Second RP"
    click_button "Save and continue"
    expect(page).to have_css("dd", text: "Second RP")
    expect(page).to have_text("Responsible Person was changed")
  end
end
