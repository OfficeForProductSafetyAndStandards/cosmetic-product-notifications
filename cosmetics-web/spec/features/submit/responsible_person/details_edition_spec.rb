require "rails_helper"

RSpec.describe "Editing responsible person details", :with_stubbed_mailer, type: :feature do
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person, name: "Test RP") }
  let(:user) { create(:submit_user) }
  let(:other_member) { create(:submit_user) }

  before do
    configure_requests_for_submit_domain
    create(:responsible_person_user, user: other_member, responsible_person:)
  end

  scenario "user not belonging to the responsible person cannot edit the Contact Person details" do
    sign_in(user)
    visit "/responsible_persons/#{responsible_person.id}"

    expect(page).not_to have_link("Edit")
  end

  scenario "user belonging to the responsible person can edit the Responsible Person address" do
    sign_in_as_member_of_responsible_person(responsible_person, user)
    visit "/responsible_persons/#{responsible_person.id}"

    expect_to_be_on__responsible_person_page
    click_link("Edit the address", href: "/responsible_persons/#{responsible_person.id}/edit")

    expect(page).to have_h1("Edit the UK Responsible Person details")
    expect_back_link_to_responsible_person_page
    expect(page).to have_checked_field("Individual or sole trader")

    # First attempts with validation error
    choose "Limited company or Limited Liability Partnership (LLP)"
    fill_in "Building and street line 1 of 2", with: ""
    fill_in "Building and street line 2 of 2", with: ""
    fill_in "Town or city", with: ""
    fill_in "County", with: ""
    fill_in "Postcode", with: ""
    click_button "Save and continue"

    expect(page).to have_h1("Edit the UK Responsible Person details")
    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link("Enter a building and street", href: "#address_line_1")
    expect(page).to have_css("p#address_line_1-error", text: "Enter a building and street")
    expect(page).to have_link("Enter a town or city", href: "#city")
    expect(page).to have_css("p#city-error", text: "Enter a town or city")
    expect(page).to have_link("Enter a county", href: "#county")
    expect(page).to have_css("p#county-error", text: "Enter a county")
    expect(page).to have_link("Enter a postcode", href: "#postal_code")
    expect(page).to have_css("p#postal_code-error", text: "Enter a postcode")

    # Successful attempt
    choose "Limited company or Limited Liability Partnership (LLP)"
    fill_in "Building and street line 1 of 2", with: "Office building name"
    fill_in "Building and street line 2 of 2", with: "Example street"
    fill_in "Town or city", with: "Manchester"
    fill_in "County", with: "Greater Manchester"
    fill_in "Postcode", with: "M3 3HF"
    click_button "Save and continue"

    expect_to_be_on__responsible_person_page
    expect(page).to have_text("The Responsible Person details were changed")
    business_type_elem = page.find("dt", text: "Business type", exact_text: true)
    expect(business_type_elem).to have_sibling("td, dd",
                                               text: "Limited company or Limited Liability Partnership (LLP)",
                                               exact_text: true)

    address_elem = page.find("dt", text: "Address", exact_text: true)
    expect(address_elem).to have_sibling("dd", text: "Office building name", exact_text: false)
    expect(address_elem).to have_sibling("dd", text: "Example street", exact_text: false)
    expect(address_elem).to have_sibling("dd", text: "Manchester", exact_text: false)
    expect(address_elem).to have_sibling("dd", text: "Greater Manchester", exact_text: false)
    expect(address_elem).to have_sibling("dd", text: "M3 3HF", exact_text: false)

    # Sends an email confirmation to the author of the address change and an alert to the other RP members
    expect(delivered_emails.size).to eq 2
    confirmation_email = delivered_emails.first
    expect(confirmation_email).to have_attributes(
      recipient: user.email,
      reference: "Send Responsible Person address change confirmation",
      template: SubmitNotifyMailer::TEMPLATES[:responsible_person_address_change_for_author],
      personalization: {
        name: user.name,
        name_of_responsible_person: responsible_person.name,
        old_rp_address: "Street address, City, AB12 3CD",
        new_rp_address: "Office building name, Example street, Manchester, Greater Manchester, M3 3HF",
      },
    )
    alert_email = delivered_emails.last
    expect(alert_email).to have_attributes(
      recipient: other_member.email,
      reference: "Send Responsible Person address change alert",
      template: SubmitNotifyMailer::TEMPLATES[:responsible_person_address_change_for_others],
      personalization: {
        name: other_member.name,
        name_of_person_who_changed_rp_address: user.name,
        name_of_responsible_person: responsible_person.name,
        old_rp_address: "Street address, City, AB12 3CD",
        new_rp_address: "Office building name, Example street, Manchester, Greater Manchester, M3 3HF",
      },
    )
  end
end
