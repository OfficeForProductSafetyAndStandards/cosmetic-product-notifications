require "rails_helper"

RSpec.describe "Editing responsible person address", type: :feature do
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person, name: "Test RP") }
  let(:user) { create(:submit_user) }

  before do
    configure_requests_for_submit_domain
  end

  scenario "user not belonging to the responsible person cannot edit the Contact Person details" do
    sign_in(user)
    visit "/responsible_persons/#{responsible_person.id}"

    expect(page).not_to have_link("Edit")
  end

  scenario "user belonging to the responsible person can edit the responsible person address" do
    sign_in_as_member_of_responsible_person(responsible_person, user)
    visit "/responsible_persons/#{responsible_person.id}"

    expect_to_be_on__responsible_person_page
    click_link("Edit the address", href: "/responsible_persons/#{responsible_person.id}/edit")

    expect(page).to have_h1("Change UK Responsible Person address for Test RP")
    expect_back_link_to_responsible_person_page

    # First attempts with validation error
    fill_in "Building and street line 1 of 2", with: ""
    fill_in "Building and street line 2 of 2", with: ""
    fill_in "Town or city", with: ""
    fill_in "County", with: ""
    fill_in "Postcode", with: ""
    click_button "Continue"

    expect(page).to have_h1("Change UK Responsible Person address for Test RP")
    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link("Enter a building and street", href: "#address_line_1")
    expect(page).to have_css("span#address_line_1-error", text: "Enter a building and street")
    expect(page).to have_link("Enter a town or city", href: "#city")
    expect(page).to have_css("span#city-error", text: "Enter a town or city")
    expect(page).to have_link("Enter a postcode", href: "#postal_code")
    expect(page).to have_css("span#postal_code-error", text: "Enter a postcode")

    # Successful attempt
    fill_in "Building and street line 1 of 2", with: "Office building name"
    fill_in "Building and street line 2 of 2", with: "Example street"
    fill_in "Town or city", with: "Manchester"
    fill_in "County", with: "Greater Manchester"
    fill_in "Postcode", with: "M3 3HF"
    click_button "Continue"

    expect_to_be_on__responsible_person_page
    expect(page).to have_text("Responsible Person address changed successfully")
    address_elem = page.find("dt", text: "Address", exact_text: true)
    expect(address_elem).to have_sibling("dd", text: "Office building name", exact_text: false)
    expect(address_elem).to have_sibling("dd", text: "Example street", exact_text: false)
    expect(address_elem).to have_sibling("dd", text: "Manchester", exact_text: false)
    expect(address_elem).to have_sibling("dd", text: "Greater Manchester", exact_text: false)
    expect(address_elem).to have_sibling("dd", text: "M3 3HF", exact_text: false)
  end
end
