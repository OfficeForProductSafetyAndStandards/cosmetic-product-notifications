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

    expect(page).not_to have_link("Edit")
  end

  scenario "user belonging to the responsible person can edit the contact person name" do
    sign_in_as_member_of_responsible_person(responsible_person, user)
    visit "/responsible_persons/#{responsible_person.id}"

    expect_to_be_on__responsible_person_page
    click_link("Edit", href: "/responsible_persons/#{responsible_person.id}/contact_persons/#{contact_person.id}/edit?field=name")

    expect(page).to have_h1("Change contact person name for Test RP")
    expect_back_link_to_responsible_person_page

    # First attempts with validation error
    fill_in "Full name", with: ""
    click_button "Continue"

    expect(page).to have_h1("Change contact person name for Test RP")
    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link("Name can not be blank", href: "#contact_person_name")
    expect(page).to have_css("span#contact_person_name-error", text: "Name can not be blank")

    fill_in "Full name", with: "Foo Bar www.example.org"
    click_button "Continue"

    expect(page).to have_h1("Change contact person name for Test RP")
    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link("Enter a valid name", href: "#contact_person_name")
    expect(page).to have_css("span#contact_person_name-error", text: "Enter a valid name")

    # Successful attempt
    fill_in "Full name", with: "Mr Foo Bar"
    click_button "Continue"

    expect_to_be_on__responsible_person_page
    expect(page).to have_text("Contact person name changed successfully")
    contact_person_name_elem = page.find_all("dt", text: "Name", exact_text: true).last
    expect(contact_person_name_elem).to have_sibling("td, dd", text: "Mr Foo Bar", exact_text: true)
  end

  scenario "user belonging to the responsible person can edit the contact person email address" do
    sign_in_as_member_of_responsible_person(responsible_person, user)
    visit "/responsible_persons/#{responsible_person.id}"

    expect_to_be_on__responsible_person_page
    click_link("Edit", href: "/responsible_persons/#{responsible_person.id}/contact_persons/#{contact_person.id}/edit?field=email_address")

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
    expect(page).to have_summary_item(key: "Email", value: "mrFooBar@example.com")
  end

  scenario "user belonging to the responsible person can edit the contact person phone number" do
    sign_in_as_member_of_responsible_person(responsible_person, user)
    visit "/responsible_persons/#{responsible_person.id}"

    expect_to_be_on__responsible_person_page
    click_link("Edit", href: "/responsible_persons/#{responsible_person.id}/contact_persons/#{contact_person.id}/edit?field=phone_number")

    expect(page).to have_h1("Change contact person phone number for Test RP")
    expect_back_link_to_responsible_person_page

    # First attempt with validation error
    fill_in "Telephone number", with: "000"
    click_button "Continue"

    expect(page).to have_h1("Change contact person phone number for Test RP")
    expected_error = "Enter a valid telephone number, like 0344 411 1444 or +44 7700 900 982"
    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link(expected_error, href: "#contact_person_phone_number")
    expect(page).to have_css("span#contact_person_phone_number-error", text: expected_error)

    # Successful attempt
    fill_in "Telephone number", with: "+44(7123456789)"
    click_button "Continue"

    expect_to_be_on__responsible_person_page
    expect(page).to have_text("Contact person phone number changed successfully")
    expect(page).to have_summary_item(key: "Telephone", value: "+44(7123456789)")
  end
end
