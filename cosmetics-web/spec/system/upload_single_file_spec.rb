require 'rails_helper'

RSpec.describe "Upload a single file", type: :system do
  before do
    allow(Keycloak::Client).to receive(:user_signed_in?).and_return(true)
  end

  after do
    allow(Keycloak::Client).to receive(:user_signed_in?).and_call_original
  end

  it "enables to upload a file" do
    responsible_person = ResponsiblePerson.create
    visit new_responsible_person_notification_file_path(responsible_person.id)
    page.attach_file('uploaded_file', Rails.root + 'spec/fixtures/testImage.png')
    click_button "Upload"

    expect(page).to have_text("Your cosmetic products")
  end
end
