require "rails_helper"

RSpec.describe "Submit user belongs to multiple responsible persons", :with_2fa, :with_stubbed_notify, type: :feature do
  let(:name_1) { "Company 1 Ltd" }
  let(:name_2) { "Company 2 Ltd" }
  let(:responsible_person_1) { create(:responsible_person, :with_a_contact_person, name: name_1) }
  let(:responsible_person_2) { create(:responsible_person, :with_a_contact_person, name: name_2) }

  let(:submit_user) { create(:submit_user) }

  before do
    configure_requests_for_submit_domain
    sign_in submit_user

    create(:responsible_person_user, user: submit_user, responsible_person: responsible_person_1)
    create(:responsible_person_user, user: submit_user, responsible_person: responsible_person_2)

    visit "/"
    select_secondary_authentication_sms
    complete_secondary_authentication_sms_with(submit_user.reload.direct_otp)
    # No current responsible person in session - so redirected to select page
    choose name_1
    click_on "Save and continue"
  end

  scenario "Changing responsible person" do
    visit "/"

    click_on "Your cosmetic products"

    expect_to_be_on_responsible_person_notifications_page(responsible_person_1)
    click_on "Responsible person"
    click_on "Change the Responsible Person"
    choose name_2
    click_on "Save and continue"
    expect_to_be_on_responsible_person_notifications_page(responsible_person_2)
  end

  scenario "Attempting to visit different from current responsible person pages redirects to change responsible person page" do
    visit("/responsible_persons/#{responsible_person_2.id}/notifications")
    expect(page).to have_h1("Change Responsible Person")

    visit("/responsible_persons/#{responsible_person_2.id}/nanomaterials")
    expect(page).to have_h1("Change Responsible Person")

    visit("/responsible_persons/#{responsible_person_2.id}")
    expect(page).to have_h1("Change Responsible Person")

    visit("/responsible_persons/#{responsible_person_2.id}/team_members")
    expect(page).to have_h1("Change Responsible Person")
  end

  scenario "Adding new responsible person" do
    visit "/"

    click_on "Your cosmetic products"

    expect_to_be_on_responsible_person_notifications_page(responsible_person_1)
    click_on "Responsible person"
    click_on "Change the Responsible Person"
    expect(page).to have_h1("Change Responsible Person")
    choose "Add a new Responsible Person"
    click_on "Save and continue"

    select_rp_business_account_type
    expect(page).to have_h1("UK Responsible Person details")

    name = "Some other responsible person"
    fill_in_rp_business_details(name: name)
    fill_in_rp_contact_details

    expect(page).to have_h1("Cosmetic products")
    expect(page).to have_css(".responsible-person-name", text: name)
  end

  scenario "Adding new responsible person - cant ommit contact details" do
    visit "/"

    click_on "Your cosmetic products"

    expect_to_be_on_responsible_person_notifications_page(responsible_person_1)
    click_on "Responsible person"
    click_on "Change the Responsible Person"
    expect(page).to have_h1("Change Responsible Person")
    choose "Add a new Responsible Person"
    click_on "Save and continue"

    select_rp_business_account_type
    expect(page).to have_h1("UK Responsible Person details")

    name = "Some other responsible person"
    fill_in_rp_business_details(name: name)

    visit "/"

    expect(page).to have_h1(/Contact person for/)
  end

  scenario "Landing page redirects to correct responsible person" do
    visit "/"
    click_on "Your cosmetic products"
    expect_to_be_on_responsible_person_notifications_page(responsible_person_1)

    visit "/responsible_persons/select"
    expect(page).to have_h1("Change Responsible Person")
    choose name_2
    click_on "Save and continue"

    visit "/"
    click_on "Your cosmetic products"
    expect_to_be_on_responsible_person_notifications_page(responsible_person_2)
  end

  def expect_to_be_on_responsible_person_notifications_page(responsible_person)
    expect(page).to have_h1("Cosmetic products")
    expect(page).to have_css(".responsible-person-name", text: responsible_person.name)
    expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/notifications")
  end
end
