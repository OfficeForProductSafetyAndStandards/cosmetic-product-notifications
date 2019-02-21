require 'rails_helper'

RSpec.describe "Upload a single file", type: :system do
  let(:responsible_person) { create(:responsible_person) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
    mock_antivirus
  end

  after do
    sign_out
    unmock_antivirus
  end

  it "enables to upload a file" do
    visit new_responsible_person_notification_file_path(responsible_person)
    page.attach_file('notification_file[uploaded_file]',
                     Rails.root + 'spec/fixtures/testExportFile.zip')
    click_button "Upload"

    expect(page).to have_text("Your cosmetic products")
  end

  it "shows an error when no file is selected for upload" do
    visit new_responsible_person_notification_file_path(responsible_person)
    click_button "Upload"
    expect(page).to have_text("No file selected")
  end

  it "set basic info of notification based on the uploaded file" do
    visit new_responsible_person_notification_file_path(responsible_person)
    page.attach_file('notification_file[uploaded_file]',
                     Rails.root + 'spec/fixtures/testExportFile.zip')
    click_button "Upload"

    5.times do
      break if not page.text.include? "Refresh the browser"

      visit responsible_person_notifications_path(responsible_person)
    end

    click_link "tab_unfinished"
    expect(page).to have_text("CTPA moisture conditioner")
    expect(page).to have_text("1000094")
  end
end
