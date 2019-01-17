require 'rails_helper'

RSpec.describe "Upload a single file", :type => :system do
  before do
    allow(Keycloak::Client).to receive(:user_signed_in?).and_return(true)
  end

  after do
    allow(Keycloak::Client).to receive(:user_signed_in?).and_call_original
  end

  it "enables to upload a file" do
    visit "/products/new"

    page.attach_file('uploaded_file', Rails.root + 'spec/fixtures/testImage.png')
    click_button "Upload"
    
    expect(page).to have_text("testImage.png")
  end
end
