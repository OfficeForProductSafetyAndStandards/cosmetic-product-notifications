require 'rails_helper'

RSpec.describe "Upload a single file errors", type: :system do
  let(:responsible_person) { create(:responsible_person) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
    mock_antivirus_api
  end

  after do
    sign_out
    unmock_antivirus_api
  end

  it "shows an error when no file is selected for upload" do
    visit new_responsible_person_notification_file_path(responsible_person)
    click_button "Upload"
    expect(page).to have_text("No files selected")
  end

  it "shows an error when the uploaded file has the wrong file type" do
    visit new_responsible_person_notification_file_path(responsible_person)
    page.attach_file('uploaded_files',
                     Rails.root + 'spec/fixtures/testImage.png')
    click_button "Upload"
    expect(page).to have_text("The uploaded file is not a ZIP file")
  end

  it "shows an error when the uploaded file exceeds the file limit" do
    allow(NotificationFile).to receive(:get_max_file_size).and_return(10)
    visit new_responsible_person_notification_file_path(responsible_person)
    page.attach_file('uploaded_files',
                     Rails.root + 'spec/fixtures/testExportFile.zip')
    click_button "Upload"
    expect(page).to have_text("The uploaded file exceeds the size limit")
  end

  it "shows an error when the uploaded file contains PDF files" do
    visit new_responsible_person_notification_file_path(responsible_person)
    page.attach_file('uploaded_files',
                     Rails.root + 'spec/fixtures/testZippedPDF.zip')
    click_button "Upload"
    expect(page).to have_text("The unzipped files are PDF files")
  end

  it "shows an error when the uploaded file does not contain a product XML file" do
    visit new_responsible_person_notification_file_path(responsible_person)
    page.attach_file('uploaded_files',
                     Rails.root + 'spec/fixtures/testNoProductFile.zip')
    click_button "Upload"
    expect(page).to have_text("The ZIP file does not contain a product XML file")
  end

  it "shows an error when a product with the same CPNP reference already exists for this RP" do
    Notification.create(responsible_person: responsible_person, cpnp_reference: "1000094")
    visit new_responsible_person_notification_file_path(responsible_person)
    page.attach_file('uploaded_files',
                     Rails.root + 'spec/fixtures/testExportFile.zip')
    click_button "Upload"
    expect(page).to have_text("A notification for this product already exists for this responsible person")
  end

  it "shows an error when the uploaded file can not be validated" do
    visit new_responsible_person_notification_file_path(responsible_person)
    page.attach_file('uploaded_files',
                     Rails.root + 'spec/fixtures/testExportWithMissingData.zip')
    click_button "Upload"
    expect(page).to have_text("Try again or manually register the product")
  end

  it "shows an error when the uploaded file contains a draft notification" do
    visit new_responsible_person_notification_file_path(responsible_person)
    page.attach_file('uploaded_files',
                     Rails.root + 'spec/fixtures/testDraftNotification.zip')
    click_button "Upload"
    expect(page).to have_text("The uploaded file is for a draft notification")
  end
end
