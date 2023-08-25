require "rails_helper"

RSpec.feature "Deactivated account", :with_stubbed_mailer, :with_stubbed_notify, :with_2fa, :feature do
  shared_examples "deactivated account" do
    context "when a user's account is deactivated" do
      scenario "user is shown a message when attempting to sign in" do
        visit "/sign-in"
        fill_in_credentials

        expect(page).to have_text("Your account has been deactivated.")
      end
    end
  end

  describe "for search" do
    before do
      configure_requests_for_search_domain
      Capybara.app_host = "http://#{ENV['SEARCH_HOST']}"
    end

    let(:user) { create(:poison_centre_user, :deactivated) }

    include_examples "deactivated account"
  end
end
