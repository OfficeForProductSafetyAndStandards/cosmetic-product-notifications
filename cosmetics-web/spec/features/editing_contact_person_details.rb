require "rails_helper"

RSpec.describe "Editing responsible person contact person details", type: :feature do
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person, name: "Test RP") }
  let(:user) { create(:submit_user) }
  let(:contact_person) { responsible_person.contact_persons.first }

  before do
    configure_requests_for_submit_domain
  end

  scenario "user not belonging to the responsible person cannot edit the Contact Person details" do
    sign_in(user)
    visit "/responsible_persons/#{responsible_person.id}"

    expect(page).not_to have_link("Change")
  end

  scenario "user belonging to the responsible person can edit the contact person name" do
    sign_in_as_member_of_responsible_person(responsible_person, user)
    visit "/responsible_persons/#{responsible_person.id}"

    expect_to_be_on__responsible_person_page
    click_link("Change", href: "/responsible_persons/#{responsible_person.id}/contact_persons/#{contact_person.id}/edit?field=name")

    expect(page).to have_h1("Change contact person name for Test RP")
    expect_back_link_to_responsible_person_page

    # First attempt with validation error
    fill_in "Full name", with: ""
    click_button "Continue"

    expect(page).to have_h1("Change contact person name for Test RP")
    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link("Name can not be blank", href: "#contact_person_name")
    expect(page).to have_css("span#contact_person_name-error", text: "Name can not be blank")

    # Successful attempt
    fill_in "Full name", with: "Mr Foo Bar"
    click_button "Continue"

    expect_to_be_on__responsible_person_page
    expect(page).to have_text("Contact person name changed successfully")
    expect(page).to have_summary_item(key: "Name", value: "Mr Foo Bar")
  end

  scenario "user belonging to the responsible person can edit the contact person email address" do
    sign_in_as_member_of_responsible_person(responsible_person, user)
    visit "/responsible_persons/#{responsible_person.id}"

    expect_to_be_on__responsible_person_page
    click_link("Change", href: "/responsible_persons/#{responsible_person.id}/contact_persons/#{contact_person.id}/edit?field=email_address")

    expect(page).to have_h1("Change contact person email address for Test RP")
    expect_back_link_to_responsible_person_page

    # First attempt with validation error
    fill_in "Email address", with: "mrFooBar"
    click_button "Continue"

    expect(page).to have_h1("Change contact person email address for Test RP")
    expected_error = "Enter the email address in the correct format, like name@example.com"
    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link(expected_error, href: "#contact_person_email_address")
    expect(page).to have_css("span#contact_person_email_address-error", text: expected_error)

    # Successful attempt
    fill_in "Email address", with: "mrFooBar@example.com"
    click_button "Continue"

    expect_to_be_on__responsible_person_page
    expect(page).to have_text("Contact person email address changed successfully")
    expect(page).to have_summary_item(key: "Email address", value: "mrFooBar@example.com")
  end

  scenario "user belonging to the responsible person can edit the contact person phone number" do
    sign_in_as_member_of_responsible_person(responsible_person, user)
    visit "/responsible_persons/#{responsible_person.id}"

    expect_to_be_on__responsible_person_page
    click_link("Change", href: "/responsible_persons/#{responsible_person.id}/contact_persons/#{contact_person.id}/edit?field=phone_number")

    expect(page).to have_h1("Change contact person phone number for Test RP")
    expect_back_link_to_responsible_person_page

    # First attempt with validation error
    fill_in "Phone number", with: "000"
    click_button "Continue"

    expect(page).to have_h1("Change contact person phone number for Test RP")
    expected_error = "Enter a valid phone number, like 0344 411 1444 or +44 7700 900 982"
    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link(expected_error, href: "#contact_person_phone_number")
    expect(page).to have_css("span#contact_person_phone_number-error", text: expected_error)

    # Successful attempt
    fill_in "Phone number", with: "+44(7123456789)"
    click_button "Continue"

    expect_to_be_on__responsible_person_page
    expect(page).to have_text("Contact person phone number changed successfully")
    expect(page).to have_summary_item(key: "Phone number", value: "+44(7123456789)")
  end
end
