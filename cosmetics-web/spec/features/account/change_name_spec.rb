require 'rails_helper'

RSpec.describe "Changing name", :with_2fa, :with_stubbed_mailer, :with_stubbed_notify, type: :feature do
  shared_examples "change name" do
    before do
      visit "/sign-in"
      fill_in_credentials

      expect(page).to have_css("h1", text: "Check your phone")
      fill_in "Enter security code", with: "#{otp_code} "
      click_on "Continue"

      click_on "Your account"
      expect_to_be_on_my_account_page

      click_on "Change name"
    end


    it "changes name properly" do
      fill_in "Name", with: ""
      click_button "Save"

      expect(page).to have_link("Name can not be blank", href: "#name")

      fill_in "Name", with: "Joe Smith"
      click_button "Save"
      expect_to_be_on_my_account_page
      expect(page).to have_text(/Name changed successfully/)
    end
  end

  describe "for search" do
    before do
      configure_requests_for_search_domain
    end

    let(:user) { create(:poison_centre_user, has_accepted_declaration: true) }

    include_examples "change name"
  end

  describe "for submit" do
    before do
      configure_requests_for_submit_domain
    end

    let(:user) { create(:submit_user, has_accepted_declaration: true) }
    let!(:responsible_person) { create(:responsible_person_user, user: user) }

    include_examples "change name"
  end
end
