require "rails_helper"

RSpec.feature "Timed out session", :feature do
  shared_examples "timed out session" do
    scenario "when a user logged in 1 hour ago" do
      travel(-1.hour) do
        sign_in user
      end

      visit path
      expect(page).to have_current_path(path)
    end

    scenario "when a user logged in 4 hours ago" do
      travel(-4.hours) do
        sign_in user
      end

      visit path
      expect(page).to have_current_path("/sign-in")
    end
  end

  describe "for submit" do
    before do
      configure_requests_for_submit_domain
    end

    describe "for user with app secondary authentication", :with_2fa_app do
      let(:user) { create(:submit_user, :with_app_secondary_authentication) }
      let(:path) { "/responsible_persons/account/overview" }

      include_examples "timed out session"
    end
  end

  describe "for search" do
    before do
      configure_requests_for_search_domain
    end

    describe "for user with app secondary authentication", :with_2fa_app do
      let(:user) { create(:poison_centre_user, :with_app_secondary_authentication) }
      let(:path) { "/notifications" }

      include_examples "timed out session"
    end
  end
end
