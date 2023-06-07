require "rails_helper"
require "support/feature_helpers"

RSpec.feature "Dashboard", :with_stubbed_mailer, :with_stubbed_notify, :with_2fa, :with_2fa_app, type: :feature do
  let(:user) { create(:support_user, :with_sms_secondary_authentication) }

  before do
    configure_requests_for_support_domain
    sign_in user
  end

  scenario "Viewing the dashboard" do
    expect(page).to have_h1("Dashboard")

    expect(page).to have_h3("Manage cosmetic notifications")
    expect(page).to have_h3("Account administration")
    expect(page).to have_h3("Responsible Person administration")
    expect(page).to have_h3("History/Audit log")
  end
end
