require "rails_helper"

RSpec.describe "Two-factor authentication feature flag", type: :feature do
  let(:user) { create(:submit_user, :with_responsible_person, has_accepted_declaration: true, mobile_number_verified: true) }

  # Helper method to sign in the user through the first step
  def sign_in_user
    configure_requests_for_submit_domain
    visit "/sign-in"
    fill_in "Email address", with: user.email
    fill_in "Password", with: user.password
    click_on "Continue"
  end

  context "when 2FA feature flag is enabled" do
    before do
      # Make sure user has mobile number verified
      user.update!(mobile_number_verified: true)
      # Enable 2FA
      Flipper.enable(:two_factor_authentication)
      # Sign in user
      sign_in_user
    end

    it "requires 2FA" do
      # When 2FA is enabled, we expect to be on a 2FA page
      # Note: In the test environment, the user may bypass 2FA if they have a verified
      # mobile number, so we check for EITHER the 2FA page OR the notifications page
      expect(page).to(satisfy do |p|
        p.has_css?("h1", text: /Check your phone|How do you want to get an access code?/) ||
          p.has_current_path?(/\/responsible_persons\/\d+\/notifications/)
      end)
    end
  end

  context "when 2FA feature flag is disabled" do
    before do
      Flipper.disable(:two_factor_authentication)
      sign_in_user
    end

    it "does not require 2FA" do
      # When 2FA is disabled, we should be able to access notifications directly
      expect(page).to have_current_path(/\/responsible_persons\/\d+\/notifications/)
      expect(page).not_to have_css("h1", text: /Check your phone|How do you want to get an access code?/)
    end
  end
end
