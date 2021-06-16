require "rails_helper"

RSpec.describe "Edit draft notification label images", :with_stubbed_antivirus, type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:notification) { create(:draft_notification, :with_label_image, responsible_person: responsible_person) }
  let(:user) { responsible_person.responsible_person_users.first.user }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  scenario "user changes the image label from the notification draft" do
    visit "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/edit"

    expect(page).to have_summary_item(key: "Label image", value: "testImage.png")
    expect(page).to have_summary_item(key: "Label image", value: "Change")
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
    click_button("Continue")

    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link("No file selected", href: "#image_upload")
    upload_product_label

    expect(page).to have_current_path(
      "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/edit",
    )
    expect(page).to have_summary_item(key: "Label image", value: "testImage.png")
    expect(page).to have_summary_item(key: "Label image", value: "Change")
  end
end
