require "rails_helper"

RSpec.describe "Changing name", :with_2fa, :with_stubbed_mailer, :with_stubbed_notify, type: :feature do
  shared_examples "change name" do
    before do
      visit "/sign-in"
      fill_in_credentials
      select_secondary_authentication_sms

      expect_to_be_on_secondary_authentication_sms_page
      complete_secondary_authentication_sms_with("#{otp_code} ")

      click_on "Your account"
      expect_to_be_on_my_account_page

      click_on "Change name"
      expect(page).to have_css("h1", text: "Change your name")
    end

    it "changes name properly" do
      # Attempts failing validations
      fill_in "Full name", with: ""
      click_button "Continue"
      expect(page).to have_link("Name cannot be blank", href: "#name")

      fill_in "Full name", with: "Julia www.example.com"
      click_button "Continue"
      expect(page).to have_link("Enter a valid name", href: "#name")

      # Finally introducing an accepted name
      fill_in "Full name", with: "Joe Smith"
      click_button "Continue"
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

    let(:user) { create(:submit_user, :with_responsible_person, has_accepted_declaration: true) }

    include_examples "change name"
  end
end
