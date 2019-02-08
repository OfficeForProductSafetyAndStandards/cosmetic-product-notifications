require 'rails_helper'

RSpec.describe "Upload a single file", type: :system do
  let(:responsible_person) { create(:responsible_person) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
    mock_antivirus
  end

  after do
    sign_out
  end

  it "enables to upload a file" do
    visit new_responsible_person_notification_file_path(responsible_person.id)
    page.attach_file('uploaded_file', Rails.root + 'spec/fixtures/5D8F949A.zip')
    click_button "Upload"

    expect(page).to have_text("Your cosmetic products")
  end

  it "set a notification name in dashboard based on the uploaded file" do
    visit new_responsible_person_notification_file_path(responsible_person.id)
    page.attach_file('uploaded_file',
                     Rails.root + 'spec/fixtures/5D8F949A.zip')
    click_button "Upload"

    5.times do
      break if not page.text.include? "Refresh the browser"

      visit responsible_person_notifications_path(responsible_person.id)
    end

    page.find_by_id("tab_unfinished").click
    expect(page).to have_text("CTPA moisture conditioner")
  end
end
