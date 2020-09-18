require "rails_helper"

RSpec.describe "Changing password", :with_2fa, :with_stubbed_mailer, :with_stubbed_notify, type: :feature do
  shared_examples "change password" do
    before do
      visit "/sign-in"
      fill_in_credentials

      expect(page).to have_css("h1", text: "Check your phone")
      fill_in "Enter security code", with: "#{otp_code} "
      click_on "Continue"

      click_on "Your account"
      expect_to_be_on_my_account_page

      wait_for = SecondaryAuthentication::TIMEOUTS[SecondaryAuthentication::CHANGE_PASSWORD]
      travel_to((wait_for + 1).seconds.from_now)

      click_on "Change password"
      expect(page).to have_css("h1", text: "Check your phone")
      fill_in "Enter security code", with: "#{otp_code} "
      click_on "Continue"
    end

    context "when the password change is fine" do
      it "changes password properly" do
        fill_in "Old password", with: user.password
        fill_in "New password", with: "user.password"
        fill_in "New password confirmation", with: "user.password"
        click_on "Save"
        expect_to_be_on_my_account_page
        expect(page).to have_text(/Password changed successfully/)
      end
    end

    context "when the update cant be done" do
      it "does not get updated when old password is wrong" do
        fill_in "Old password", with: "user.password"
        fill_in "New password", with: "user.password"
        fill_in "New password confirmation", with: "user.password"
        click_on "Save"

        expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
        expect(page).to have_link("Old password is incorrect", href: "#old_password")
      end

      it "does not get updated when new password does not fit to requirement" do
        fill_in "Old password", with: user.password
        fill_in "New password", with: "user"
        fill_in "New password confirmation", with: "user.password"
        click_on "Save"

        expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
        expect(page).to have_link("Password is too short (minimum is 6 characters)", href: "#password")
      end

      it "does not get updated when new password confirmation is wrong" do
        fill_in "Old password", with: user.password
        fill_in "New password", with: "user.password"
        fill_in "New password confirmation", with: "user"
        click_on "Save"

        expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
        expect(page).to have_link("Password and confirmation does not match", href: "#password_confirmation")
      end
    end
  end

  describe "for search" do
    before do
      configure_requests_for_search_domain
    end

    let(:user) { create(:poison_centre_user, has_accepted_declaration: true) }

    include_examples "change password"
  end

  describe "for submit" do
    before do
      configure_requests_for_submit_domain
    end

    let(:user) { create(:submit_user, has_accepted_declaration: true) }
    let!(:responsible_person) { create(:responsible_person_user, user: user) }

    include_examples "change password"
  end
end
