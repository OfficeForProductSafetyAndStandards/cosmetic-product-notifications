require "rails_helper"
require "support/feature_helpers"

RSpec.feature "Responsible Person administration", :with_2fa, :with_2fa_app, :with_stubbed_mailer, :with_stubbed_notify, type: :feature do
  let(:user) { create(:support_user, :with_sms_secondary_authentication) }
  let(:responsible_person_a) { create(:responsible_person) }
  let(:responsible_person_b) { create(:responsible_person) }
  let(:responsible_person_c) { create(:responsible_person, name: "#{responsible_person_b.name} 2") }
  let(:assigned_contact) { create(:contact_person, responsible_person: responsible_person_b) }

  before do
    configure_requests_for_support_domain

    responsible_person_a
    responsible_person_b
    responsible_person_c
    assigned_contact

    sign_in user
  end

  scenario "Searching for a Responsible Person that exists" do
    expect(page).to have_h1("Dashboard")

    click_link "Responsible Person administration"

    expect(page).to have_h1("Search for a Responsible Person account")

    fill_in "Enter a search term", with: responsible_person_a.name
    click_on "Search", match: :first

    expect(page).to have_text(responsible_person_a.name)
    expect(page).not_to have_text(responsible_person_b.name)
    expect(page).not_to have_text(responsible_person_c.name)
  end

  scenario "Searching for a Responsible Person that exists with multiple results" do
    expect(page).to have_h1("Dashboard")

    click_link "Responsible Person administration"

    expect(page).to have_h1("Search for a Responsible Person account")

    fill_in "Enter a search term", with: responsible_person_b.name
    click_on "Search", match: :first

    expect(page).to have_text(responsible_person_b.name)
    expect(page).to have_text(responsible_person_c.name)
    expect(page).not_to have_text(responsible_person_a.name)
  end

  scenario "Searching for a Responsible Person that doesn't exist" do
    expect(page).to have_h1("Dashboard")

    click_link "Responsible Person administration"

    expect(page).to have_h1("Search for a Responsible Person account")

    fill_in "Enter a search term", with: "Random name"
    click_on "Search", match: :first

    expect(page).to have_text('There are no Responsible Person accounts for "Random name".')

    click_on "Clear search results"

    expect(page).to have_text("Enter a search term")
  end

  scenario "Searching for an empty string" do
    expect(page).to have_h1("Dashboard")

    click_link "Responsible Person administration"

    expect(page).to have_h1("Search for a Responsible Person account")

    click_on "Search", match: :first

    expect(page).to have_text(responsible_person_a.name)
    expect(page).to have_text(responsible_person_b.name)
    expect(page).to have_text(responsible_person_c.name)
  end

  scenario "Viewing Responsible Person account details" do
    visit "/responsible-persons/#{responsible_person_a.id}"

    expect(page).to have_text(responsible_person_a.name)
    expect(page).to have_text(responsible_person_a.address_line_1)
    expect(page).to have_text(responsible_person_a.address_line_2) unless responsible_person_a.address_line_2.nil?
    expect(page).to have_text(responsible_person_a.city)
    expect(page).to have_text(responsible_person_a.county) unless responsible_person_a.county.nil?
    expect(page).to have_text(responsible_person_a.postal_code)
    expect(page).to have_text(responsible_person_a.account_type == "individual" ? /Individual/ : /Limited company/)
  end

  scenario "Viewing Responsible Person account details with an assigned contact" do
    visit "/responsible-persons/#{responsible_person_b.id}"

    expect(page).to have_text(assigned_contact.name)
    expect(page).to have_text(assigned_contact.email_address)
    expect(page).to have_text(assigned_contact.phone_number)
  end

  scenario "Changing the name on a Responsible Person account" do
    existing_name = responsible_person_a.name

    visit "/responsible-persons/#{responsible_person_a.id}"

    click_link "Change Responsible Person name"

    expect(page).to have_h1("Change Responsible Person account name")

    fill_in "Full name", with: ""
    click_on "Save changes"

    expect(page).to have_link("Name cannot be blank", href: "#responsible-person-name-field-error")

    fill_in "Full name", with: "This is a different name"
    click_on "Save changes"

    expect(page).to have_css("div.govuk-notification-banner", text: "The Responsible Person name has been updated from #{existing_name} to This is a different name")
  end

  scenario "Changing the address on a Responsible Person account" do
    existing_address = [
      responsible_person_a.address_line_1,
      responsible_person_a.address_line_2,
      responsible_person_a.city,
      responsible_person_a.county,
      responsible_person_a.postal_code,
    ].reject(&:blank?).compact.join(", ")

    visit "/responsible-persons/#{responsible_person_a.id}"

    click_link "Change Responsible Person address"

    expect(page).to have_h1("Change Responsible Person address")

    fill_in "Building and street", with: ""
    click_on "Save changes"

    expect(page).to have_link("Enter a building and street", href: "#responsible-person-address-line-1-field-error")

    fill_in "Building and street", with: "10 Downing Street"
    fill_in "responsible_person[address_line_2]", with: ""
    fill_in "Town or city", with: "London"
    fill_in "County", with: ""
    fill_in "Postcode", with: "SW1A 2AA"
    click_on "Save changes"

    expect(page).to have_css("div.govuk-notification-banner", text: "The Responsible Person address has been updated from #{existing_address} to 10 Downing Street, London, SW1A 2AA")
  end

  scenario "Changing the business type on a Responsible Person account" do
    existing_business_type = responsible_person_a.account_type == "individual" ? "Individual or sole trader" : "Limited company or Limited Liability Partnership (LLP)"
    new_business_type = responsible_person_a.account_type == "individual" ? "Limited company or Limited Liability Partnership (LLP)" : "Individual or sole trader"

    visit "/responsible-persons/#{responsible_person_a.id}"

    click_link "Change Responsible Person business type"

    expect(page).to have_h1("Change Responsible Person business type")

    # Choose the opposite option
    choose new_business_type
    click_on "Save changes"

    expect(page).to have_css("div.govuk-notification-banner", text: "The Responsible Person business type has been updated from #{existing_business_type} to #{new_business_type}")
  end

  scenario "Changing the name on an assigned contact" do
    existing_name = assigned_contact.name

    visit "/responsible-persons/#{responsible_person_b.id}"

    click_link "Change assigned contact name"

    expect(page).to have_h1("Change assigned contact name")

    fill_in "Full name", with: ""
    click_on "Save changes"

    expect(page).to have_link("Name cannot be blank", href: "#contact-person-name-field-error")

    fill_in "Full name", with: "This is a different name"
    click_on "Save changes"

    expect(page).to have_css("div.govuk-notification-banner", text: "The assigned contact name has been updated from #{existing_name} to This is a different name")
  end

  scenario "Changing the email on an assigned contact" do
    existing_email = assigned_contact.email_address

    visit "/responsible-persons/#{responsible_person_b.id}"

    click_link "Change assigned contact email"

    expect(page).to have_h1("Change assigned contact email address")

    fill_in "Email address", with: ""
    click_on "Save changes"

    expect(page).to have_link("Enter an email", href: "#contact-person-email-address-field-error")

    fill_in "Email address", with: "something@something@example.com"
    click_on "Save changes"

    expect(page).to have_link("Enter an email in the correct format, like name@example.com", href: "#contact-person-email-address-field-error")

    fill_in "Email address", with: "something@example.com"
    click_on "Save changes"

    expect(page).to have_css("div.govuk-notification-banner", text: "The assigned contact email address has been updated from #{existing_email} to something@example.com")
  end

  scenario "Changing the contact number on an assigned contact" do
    existing_contact_number = assigned_contact.phone_number

    visit "/responsible-persons/#{responsible_person_b.id}"

    click_link "Change assigned contact contact number"

    expect(page).to have_h1("Change assigned contact contact number")

    fill_in "Contact number", with: ""
    click_on "Save changes"

    expect(page).to have_link("Telephone cannot be blank", href: "#contact-person-phone-number-field-error")

    fill_in "Contact number", with: "01234567890"
    click_on "Save changes"

    expect(page).to have_css("div.govuk-notification-banner", text: "The assigned contact contact number has been updated from #{existing_contact_number} to 01234567890")
  end
end
