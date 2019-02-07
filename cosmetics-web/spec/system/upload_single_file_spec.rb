require 'rails_helper'

RSpec.describe "Upload a single file", type: :system do
  let(:responsible_person) { create(:responsible_person) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out
  end

  it "enables to upload a file" do
    visit new_responsible_person_notification_file_path(responsible_person.id)
    page.attach_file('uploaded_file', Rails.root + 'spec/fixtures/testImage.png')
    click_button "Upload"

    expect(page).to have_text("Your cosmetic products")
  end
end
