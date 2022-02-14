# TODELETE
require "rails_helper"

RSpec.describe "Edit draft notification before submitting it", :with_stubbed_antivirus, type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:user) { responsible_person.responsible_person_users.first.user }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  scenario "user changes the image label from the notification draft" do
    notification = create(:draft_notification, :with_label_image, responsible_person: responsible_person)
    visit "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/edit"

    expect(page).to have_summary_item(key: "Label image", value: "testImage.png")
    expect(page).to have_summary_item(key: "Label image", value: "Change label image")
    click_link "Change"

    expect(page).to have_current_path(
      "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/product_image_upload/edit",
    )
    expect(page).to have_h1("Upload an image of the product label")
    expect(page).to have_link(
      "Back",
      href: "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/edit",
    )
    expect(page).to have_text("Label images")
    expect(page).to have_summary_item(key: "testImage.png", value: "Remove")
    click_link "Remove"

    expect(page).to have_h1("Upload an image of the product label")
    expect(page).to have_current_path(
      "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/product_image_upload/edit",
    )
    expect(page).not_to have_text("Label images")
    expect(page).not_to have_summary_item(key: "testImage.png", value: "Remove")
    click_button("Save and continue")

    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link("No file selected", href: "#image_upload")

    page.attach_file "spec/fixtures/files/testImage.png"
    click_button "Save and continue"
    expect(page).to have_current_path(
      "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/edit",
    )
    expect(page).to have_summary_item(key: "Label image", value: "testImage.png")
    expect(page).to have_summary_item(key: "Label image", value: "Change label image")
  end

  scenario "user changes the formulation file from the notification draft" do
    component = create(:component, :using_exact, :with_formulation_file)
    notification = create(:draft_notification, responsible_person: responsible_person, components: [component])

    visit "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/edit"

    expect(page).to have_summary_item(key: "Formulation", value: "testPdf.pdf")
    expect(page).to have_summary_item(key: "Formulation", value: "Change formulation document")
    click_link "Change"

    expect(page).to have_current_path(
      "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/components/#{component.id}/formulation/edit",
    )
    expect(page).to have_h1("Exact concentrations of the ingredients")
    expect(page).to have_link(
      "Back",
      href: "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/edit",
    )
    expect(page).to have_text("Upload a file")
    expect(page).to have_summary_item(key: "testPdf.pdf", value: "Remove")

    # User cannot upload a new formulation file until removing the existing one
    expect(page).not_to have_field("formulation_file")

    # User can keep the same attachment
    click_button "Save and continue"
    expect(page).to have_current_path(
      "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/edit",
    )
    expect(page).to have_summary_item(key: "Formulation", value: "testPdf.pdf")
    expect(page).to have_summary_item(key: "Formulation", value: "Change formulation document")

    # User goes back to edit the formulation page
    click_link "Change"
    expect(page).to have_current_path(
      "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/components/#{component.id}/formulation/edit",
    )
    expect(page).to have_h1("Exact concentrations of the ingredients")
    expect(page).to have_link(
      "Back",
      href: "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/edit",
    )
    expect(page).to have_text("Upload a file")
    expect(page).to have_summary_item(key: "testPdf.pdf", value: "Remove")

    # User cannot upload a new formulation file until removing the existing one
    expect(page).not_to have_field("formulation_file")

    # User removes the existing formulation file
    click_link "Remove"
    expect(page).to have_current_path(
      "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/components/#{component.id}/formulation/edit",
    )
    expect(page).to have_h1("Exact concentrations of the ingredients")
    expect(page).to have_field("formulation_file")

    # User uploads a new formulation file
    page.attach_file "spec/fixtures/files/testPdf.pdf"
    click_button "Save and continue"

    expect(page).to have_current_path(
      "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/edit",
    )
    expect(page).to have_summary_item(key: "Formulation", value: "testPdf.pdf")
    expect(page).to have_summary_item(key: "Formulation", value: "Change formulation document")
  end
end
