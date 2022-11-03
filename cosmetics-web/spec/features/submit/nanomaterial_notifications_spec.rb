require "rails_helper"

RSpec.describe "Nanomaterial notifications", type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:submit_user) { responsible_person.responsible_person_users.first.user }

  before do
    travel_to(Time.zone.local(2021, 6, 10))
    sign_in_as_member_of_responsible_person(responsible_person, submit_user)
  end

  describe "CSV download" do
    context "when nanomaterial notications are present", :with_stubbed_antivirus do
      let(:user_id) { submit_user.id }
      let(:rp) { responsible_person }
      let(:nanomaterial_notification1) { create(:nanomaterial_notification, :submittable, :submitted, user_id:, responsible_person: rp) }
      let(:nanomaterial_notification2) { create(:nanomaterial_notification, :submittable, :submitted, user_id:, responsible_person: rp, notified_to_eu_on: 3.days.ago.to_date) }
      let(:nanomaterial_notification3) { create(:nanomaterial_notification, user_id:, responsible_person: rp) }

      before do
        nanomaterial_notification1
        nanomaterial_notification2
        nanomaterial_notification3
      end

      scenario "CSV download link" do
        visit "/responsible_persons/#{responsible_person.id}/nanomaterials"

        expect(page).to have_selector("a", text: "Download a CSV file of notified nanomaterials")
      end
    end

    scenario "CSV download link is invisible when no nano notifications" do
      visit "/responsible_persons/#{responsible_person.id}/nanomaterials"

      expect(page).not_to have_selector("a", text: "Download a CSV file of notified nanomaterials")
    end
  end

  scenario "submitting a nanomaterial that has not been notified to the EU", :with_stubbed_antivirus do
    visit "/responsible_persons/#{responsible_person.id}/nanomaterials"

    click_link "Add a nanomaterial"

    fill_in "What is the name of the nanomaterial?", with: "My nanomaterial"
    click_button "Continue"

    expect(page).to have_selector("h1", text: "Was the EU notified about My nanomaterial on CPNP before 1 January 2021?")
    choose "No"
    click_button "Continue"

    expect(page).to have_selector("h1", text: "Upload details about the nanomaterial")
    attach_file "Upload a file", Rails.root.join("spec/fixtures/files/testPdf.pdf")
    click_button "Continue"

    expect(page).to have_selector("h1", text: "Check your answers")
    click_button "Accept and send"

    expect(page).to have_text("You have told us about My nanomaterial")
    click_link "Return to Nanomaterials"

    last_notification = NanomaterialNotification.last
    expect(page).to have_link("My nanomaterial")
    expect(page).to have_selector("td[headers='uknotified item-1 meta-1']", text: "10 June 2021")
    expect(page).to have_selector("td[headers='eunotified item-1 meta-1']", text: "No")
    expect(page).to have_selector("td[headers='reviewperiodenddate item-1 meta-1']", text: "10 December 2021")
    expect(page).to have_selector("td[headers='uknumber item-1 meta-1']", text: last_notification.ukn)

    click_link("My nanomaterial")
    expect(page).to have_current_path("/nanomaterials/#{last_notification.id}")
    expect(page).to have_h1("My nanomaterial")
    expect(page).to have_summary_item(key: "Notified in the UK", value: "10 June 2021")
    expect(page).to have_summary_item(key: "Notified in the EU", value: "No")
    expect(page).to have_summary_item(key: "Review period end", value: "10 December 2021")
    expect(page).to have_summary_item(key: "UK nanomaterial number", value: last_notification.ukn)
    expect(page).to have_selector("dd.govuk-summary-list__value", text: "testPdf.pdf (PDF, 11.6 KB)")
  end

  scenario "submitting a nanomaterial which was previously notified to the EU", :with_stubbed_antivirus do
    visit "/responsible_persons/#{responsible_person.id}/nanomaterials"

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
    attach_file "Upload a file", Rails.root.join("spec/fixtures/files/testPdf.pdf")
    click_button "Continue"

    expect(page).to have_selector("h1", text: "Check your answers")
    click_button "Accept and send"

    expect(page).to have_text("You have told us about My EU nanomaterial")
    click_link "Return to Nanomaterials"

    last_notification = NanomaterialNotification.last
    expect(page).to have_link("My EU nanomaterial")
    expect(page).to have_selector("td[headers='uknotified item-1 meta-1']", text: "10 June 2021")
    expect(page).to have_selector("td[headers='eunotified item-1 meta-1']", text: "1 February 2017")
    expect(page).to have_selector("td[headers='reviewperiodenddate item-1 meta-1']", text: "1 August 2017")
    expect(page).to have_selector("td[headers='uknumber item-1 meta-1']", text: last_notification.ukn)

    click_link("My EU nanomaterial")
    expect(page).to have_current_path("/nanomaterials/#{last_notification.id}")
    expect(page).to have_h1("My EU nanomaterial")
    expect(page).to have_summary_item(key: "Notified in the UK", value: "10 June 2021")
    expect(page).to have_summary_item(key: "Notified in the EU", value: "1 February 2017")
    expect(page).to have_summary_item(key: "Review period end", value: "1 August 2017")
    expect(page).to have_summary_item(key: "UK nanomaterial number", value: last_notification.ukn)
    expect(page).to have_selector("dd.govuk-summary-list__value", text: "testPdf.pdf (PDF, 11.6 KB)")
  end
end
