require "rails_helper"

RSpec.describe "Nanomaterial notifications", type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)

    visit "/responsible_persons/#{responsible_person.id}/nanomaterials"
  end

  scenario "submitting a nanomaterial that has not been notified to the EU" do
    click_link "Add nanomaterial"

    fill_in "What is the name of the nanomaterial?", with: "My nanomaterial"
    click_button "Continue"

    expect(page).to have_selector("h1", text: "Was the EU notified about My nanomaterial on CPNP before 1 February 2020?")
    choose "No"
    click_button "Continue"

    expect(page).to have_selector("h1", text: "Upload details about the nanomaterial")
    attach_file "Upload a file", Rails.root + "spec/fixtures/testPdf.pdf"
    click_button "Continue"

    expect(page).to have_selector("h1", text: "Check your answers")
    click_button "Accept and send"

    expect(page).to have_text("You’ve told us about My nanomaterial")
  end

  scenario "submitting a nanomaterial which was previously notified to the EU" do
    click_link "Add nanomaterial"

    fill_in "What is the name of the nanomaterial?", with: "My EU nanomaterial"
    click_button "Continue"

    expect(page).to have_selector("h1", text: "Was the EU notified about My EU nanomaterial on CPNP before 1 February 2020?")
    choose "Yes, the EU was notified about the nanomaterial on CPNP before 1 February 2020"
    fill_in "Day", with: "01"
    fill_in "Month", with: "02"
    fill_in "Year", with: "2017"
    click_button "Continue"

    expect(page).to have_selector("h1", text: "Upload details about the nanomaterial")
    attach_file "Upload a file", Rails.root + "spec/fixtures/testPdf.pdf"
    click_button "Continue"

    expect(page).to have_selector("h1", text: "Check your answers")
    click_button "Accept and send"

    expect(page).to have_text("You’ve told us about My EU nanomaterial")
  end
end
