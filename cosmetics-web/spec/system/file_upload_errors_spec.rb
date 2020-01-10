require "rails_helper"

RSpec.describe "File upload errors", :with_stubbed_antivirus, type: :system do
  let(:responsible_person) { create(:responsible_person) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out
  end

  it "shows an error when no file is selected for upload" do
    visit new_responsible_person_notification_file_path(responsible_person)
    click_button "Continue"
    expect(page).to have_text("Select an EU notification file")
  end

  it "shows an error when too many files are selected for upload" do
    allow(NotificationFile).to receive(:get_max_number_of_files).and_return(2)
    upload_files ["testExportFile.zip"] * 3
    expect(page).to have_text("You can only select up to 2 files at the same time")
  end

  it "shows an error when the uploaded file has the wrong file type" do
    upload_file "testImage.png"
    expect(page).to have_text("The uploaded file is not a ZIP file")
  end

  it "shows an error when the uploaded file exceeds the file limit" do
    allow(NotificationFile).to receive(:get_max_file_size).and_return(10)
    upload_file "testExportFile.zip"
    expect(page).to have_text("The uploaded file exceeds the size limit")
  end

  it "shows an error when the uploaded file contains PDF files" do
    upload_file "testZippedPDF.zip"
    expect(page).to have_text("The unzipped files are PDF files")
  end

  it "shows an error when the uploaded file does not contain a product XML file" do
    upload_file "testNoProductFile.zip"
    expect(page).to have_text("The ZIP file does not contain a product XML file")
  end

  it "shows an error when a product with the same CPNP reference already exists for this Responsible Person" do
    create(:registered_notification, responsible_person: responsible_person, cpnp_reference: "1000094")
    upload_file "testExportFile.zip"
    expect(page).to have_text("A notification for this product already exists for this responsible person")
  end

  it "shows an error when the uploaded file can not be validated" do
    upload_file "testExportWithMissingData.zip"
    expect(page).to have_text("Try again or manually enter the production notification data")
  end

  it "shows an error when the uploaded file contains a draft notification" do
    upload_file "testDraftNotification.zip"
    expect(page).to have_text("The uploaded file is for a draft notification")
  end

private

  def upload_file(filename)
    upload_files([filename])
  end

  def upload_files(filenames)
    visit new_responsible_person_notification_file_path(responsible_person)
    attach_file "uploaded_files", (filenames.map { |filename| Rails.root + "spec/fixtures/#{filename}" })
    click_button "Continue"
  end
end
