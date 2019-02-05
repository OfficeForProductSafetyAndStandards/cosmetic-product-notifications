require 'rails_helper'

RSpec.describe "Upload a single file", type: :system do
  before do
    authenticate_user
  end

  after do
    sign_out_user
  end

  it "enables to upload a file" do
    visit new_notification_file_path

    page.attach_file('uploaded_file', Rails.root + 'spec/fixtures/testImage.png')
    click_button "Upload"

    expect(page).to have_text("testImage.png")
  end
end
