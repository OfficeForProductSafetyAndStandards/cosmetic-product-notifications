require "rails_helper"

RSpec.describe "Nanomaterial notifications", type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }

  before do
    travel_to(Time.zone.local(2021, 6, 10))
    sign_in_as_member_of_responsible_person(responsible_person)

    visit "/responsible_persons/#{responsible_person.id}/nanomaterials"
  end

  scenario "CSV download link" do
    expect(page).to have_selector("a", text: "Download a CSV file of notified nanomaterials")
  end

  scenario "submitting a nanomaterial that has not been notified to the EU", :with_stubbed_antivirus do
    click_link "Add a nanomaterial"

    fill_in "What is the name of the nanomaterial?", with: "My nanomaterial"
    click_button "Continue"

    expect(page).to have_selector("h1", text: "Was the EU notified about My nanomaterial on CPNP before 1 January 2021?")
    choose "No"
    click_button "Continue"

    expect(page).to have_selector("h1", text: "Upload details about the nanomaterial")
    attach_file "Upload a file", Rails.root + "spec/fixtures/files/testPdf.pdf"
    click_button "Continue"

    expect(page).to have_selector("h1", text: "Check your answers")
    click_button "Accept and send"

    expect(page).to have_text("You’ve told us about My nanomaterial")
    click_link "Return to Nanomaterials"

    id = NanomaterialNotification.last.id
    expect(page).to have_link("My nanomaterial")
    expect(page).to have_summary_item(key: "Notified in the UK", value: "10 June 2021")
    expect(page).to have_summary_item(key: "Notified in the EU", value: "No")
    expect(page).to have_summary_item(key: "UK nanomaterial number", value: "UKN-#{id}")

    click_link("My nanomaterial")
    expect(page).to have_current_path("/nanomaterials/#{id}")
    expect(page).to have_h1("My nanomaterial")
    expect(page).to have_summary_item(key: "Notified in the UK", value: "10 June 2021")
    expect(page).to have_summary_item(key: "Notified in the EU", value: "No")
    expect(page).to have_summary_item(key: "UK nanomaterial number", value: "UKN-#{id}")
    expect(page).to have_summary_item(key: "PDF file", value: "testPdf.pdf")
  end

  scenario "submitting a nanomaterial which was previously notified to the EU", :with_stubbed_antivirus do
    click_link "Add a nanomaterial"

    fill_in "What is the name of the nanomaterial?", with: "My EU nanomaterial"
    click_button "Continue"

    expect(page).to have_selector("h1", text: "Was the EU notified about My EU nanomaterial on CPNP before 1 January 2021?")
    choose "Yes, the EU was notified about the nanomaterial on CPNP before 1 January 2021"
    fill_in "Day", with: "01"
    fill_in "Month", with: "02"
    fill_in "Year", with: "2017"
    click_button "Continue"

    expect(page).to have_selector("h1", text: "Upload details about the nanomaterial")
    attach_file "Upload a file", Rails.root + "spec/fixtures/files/testPdf.pdf"
    click_button "Continue"

    expect(page).to have_selector("h1", text: "Check your answers")
    click_button "Accept and send"

    expect(page).to have_text("You’ve told us about My EU nanomaterial")
    click_link "Return to Nanomaterials"

    id = NanomaterialNotification.last.id
    expect(page).to have_link("My EU nanomaterial")
    expect(page).to have_summary_item(key: "Notified in the UK", value: "10 June 2021")
    expect(page).to have_summary_item(key: "Notified in the EU", value: "1 February 2017")
    expect(page).to have_summary_item(key: "UK nanomaterial number", value: "UKN-#{id}")

    click_link("My EU nanomaterial")
    expect(page).to have_current_path("/nanomaterials/#{id}")
    expect(page).to have_h1("My EU nanomaterial")
    expect(page).to have_summary_item(key: "Notified in the UK", value: "10 June 2021")
    expect(page).to have_summary_item(key: "Notified in the EU", value: "1 February 2017")
    expect(page).to have_summary_item(key: "UK nanomaterial number", value: "UKN-#{id}")
    expect(page).to have_summary_item(key: "PDF file", value: "testPdf.pdf")
  end
end
