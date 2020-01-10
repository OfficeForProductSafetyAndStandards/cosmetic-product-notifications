require "rails_helper"

RSpec.describe "File upload", :with_stubbed_antivirus, type: :system do
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out
  end

  it "allows a single file to be uploaded" do
    upload_file "testExportFile.zip"
    expect(page).to have_text("Your cosmetic products")
  end

  it "allows multiple files to be uploaded" do
    upload_files %w[testExportFile.zip testExportFile2.zip]
    expect(page).to have_text("Your cosmetic products")
  end

  it "sets basic info of notification based on the uploaded file" do
    upload_file "testExportFile.zip"
    wait_until_processing_complete
    click_link "tab_incomplete"

    expect(page).to have_text("CTPA moisture conditioner")
    expect(page).to have_text("1000094")
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

  def wait_until_processing_complete
    5.times do
      break unless page.text.include? "Refresh the browser"

      visit responsible_person_notifications_path(responsible_person)
    end
  end
end
