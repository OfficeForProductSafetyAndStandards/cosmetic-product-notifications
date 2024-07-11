require "rails_helper"

RSpec.describe "Submit user belongs to multiple responsible persons", :with_2fa, :with_stubbed_notify, type: :feature do
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
    choose name_a
    click_on "Save and continue"
  end

  scenario "Changing responsible person" do
    visit "/"

    click_on "cosmetic products page"

    expect_to_be_on_responsible_person_notifications_page(responsible_person_a)
    click_on "Responsible Person"
    expect(page).to have_css("dd", text: name_a)
    click_on "Change the Responsible Person"
    choose name_b
    click_on "Save and continue"
    expect(page).to have_h1("Responsible Person")
    expect(page).to have_css("dd", text: name_b)
    expect(page).to have_text("Responsible Person was changed")
    expect(page).to have_current_path("/responsible_persons/#{responsible_person_b.id}")
  end

  scenario "Attempting to visit different from current responsible person pages redirects to change responsible person page" do
    visit("/responsible_persons/#{responsible_person_b.id}/notifications")
    expect(page).to have_h1("Change the Responsible Person")

    visit("/responsible_persons/#{responsible_person_b.id}/nanomaterials")
    expect(page).to have_h1("Change the Responsible Person")

    visit("/responsible_persons/#{responsible_person_b.id}")
    expect(page).to have_h1("Change the Responsible Person")

    visit("/responsible_persons/#{responsible_person_b.id}/team_members")
    expect(page).to have_h1("Change the Responsible Person")
  end

  scenario "Adding new responsible person" do
    visit "/"

    click_on "cosmetic products page"

    expect_to_be_on_responsible_person_notifications_page(responsible_person_a)
    click_on "Responsible Person"
    click_on "Change the Responsible Person"
    expect(page).to have_h1("Change the Responsible Person")
    choose "Add a new Responsible Person"
    click_on "Save and continue"

    expect(page).to have_h1("Add a Responsible Person")

    name = "Some other responsible person"
    fill_in_rp_business_details(name:)
    fill_in_rp_contact_details

    expect(page).to have_h1("Responsible Person")
    expect(page).to have_text(responsible_person_a.name)
  end

  scenario "Adding new responsible person - cant ommit contact details" do
    visit "/"

    click_on "cosmetic products page"

    expect_to_be_on_responsible_person_notifications_page(responsible_person_a)
    click_on "Responsible Person"
    click_on "Change the Responsible Person"
    expect(page).to have_h1("Change the Responsible Person")
    choose "Add a new Responsible Person"
    click_on "Save and continue"

    expect(page).to have_h1("Add a Responsible Person")

    name = "Some other responsible person"
    fill_in_rp_business_details(name:)

    visit "/"

    expect(page).to have_h1(/Contact person for/)
  end

  scenario "Landing page redirects to correct responsible person" do
    visit "/"
    click_on "cosmetic products page"
    expect_to_be_on_responsible_person_notifications_page(responsible_person_a)

    visit "/responsible_persons/select"
    expect(page).to have_h1("Change the Responsible Person")
    choose name_b
    click_on "Save and continue"

    visit "/"
    click_on "cosmetic products page"
    expect_to_be_on_responsible_person_notifications_page(responsible_person_b)
  end

  def expect_to_be_on_responsible_person_notifications_page(responsible_person)
    expect(page).to have_h1("Product notifications")
    expect(page).to have_css(".responsible-person-name", text: responsible_person.name)
    expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/notifications")
  end
end
