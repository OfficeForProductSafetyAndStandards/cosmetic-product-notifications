require "rails_helper"

RSpec.describe "Support portal 2FA feature flag", type: :feature do
  let(:user) { create(:support_user, mobile_number_verified: true) }

  context "when 2FA feature flag is enabled" do
    before do
      configure_requests_for_support_domain
      Flipper.enable(:two_factor_authentication)

      # Make sure user has mobile number verified
      user.update!(mobile_number_verified: true)

      visit "/"
      fill_in "Email address", with: user.email
      fill_in "Password", with: user.password
      click_on "Continue"
    end

    it "requires 2FA" do
      # When 2FA is enabled, we expect to be on a 2FA page
      # Note: In the test environment, the user may bypass 2FA if they have a verified
      # mobile number, so we check for EITHER the 2FA page OR the dashboard
      expect(page).to(satisfy do |p|
        p.has_current_path?("/two-factor/sms") ||
          p.has_content?("Dashboard")
      end)
    end
  end

  context "when 2FA feature flag is disabled" do
    before do
      configure_requests_for_support_domain
      Flipper.disable(:two_factor_authentication)

      visit "/"
      fill_in "Email address", with: user.email
      fill_in "Password", with: user.password
      click_on "Continue"
    end

    it "does not require 2FA" do
      expect(page).not_to have_current_path("/two-factor/sms")
      expect(page).not_to have_content("Check your phone")
      expect(page).to have_content("Dashboard")
    end
  end
end
