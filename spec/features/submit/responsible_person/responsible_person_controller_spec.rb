require "rails_helper"

RSpec.describe "Submit user change responsible person", :with_2fa, :with_stubbed_notify, type: :feature do
  let(:name_a) { "Company 1 Ltd" }
  let(:name_b) { "Company 2 Ltd" }
  let(:responsible_person_a) { create(:responsible_person, :with_a_contact_person, name: name_a) }
  let(:responsible_person_b) { create(:responsible_person, :with_a_contact_person, name: name_b) }

  let(:submit_user) { create(:submit_user) }

  before do
    configure_requests_for_submit_domain
    sign_in submit_user

    create(:responsible_person_user, user: submit_user, responsible_person: responsible_person_a)
    create(:responsible_person_user, user: submit_user, responsible_person: responsible_person_b)

    visit "/"
    select_secondary_authentication_sms
    complete_secondary_authentication_sms_with(submit_user.reload.direct_otp)
    # No current responsible person in session - so redirected to select page
  end

  scenario "sign in with multiple responsible person user and change responsible person" do
    visit("/")
    expect(page).to have_content("Select the Responsible Person")
    choose name_a
    click_on "Save and continue"
    expect(page).to have_h1("Responsible Person")
    expect(page).to have_text(responsible_person_a.name)
    click_on "Change the Responsible Person"
    choose name_b
    click_on "Save and continue"
    expect(page).to have_h1("Responsible Person")
    expect(page).to have_text(responsible_person_b.name)
  end

  scenario "sign in with multiple responsible person user without selection" do
    visit("/")
    expect(page).to have_content("Select the Responsible Person")
    choose name_a
    click_on "Save and continue"
    expect(page).to have_h1("Responsible Person")
    expect(page).to have_text(responsible_person_a.name)
    click_on "Change the Responsible Person"
    click_on "Save and continue"
    expect(page).to have_text("There is a problem")
    expect(page).to have_text("Select a Responsible Person or add a new Responsible Person")
  end
end
