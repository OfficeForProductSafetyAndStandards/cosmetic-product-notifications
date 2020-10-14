require "rails_helper"

RSpec.describe "Changing email address", :with_2fa, :with_stubbed_mailer, :with_stubbed_notify, type: :feature do
  describe "submit domain" do
    let(:old_email) { "old@example.org" }
    let(:user) { create(:submit_user, :with_responsible_person, has_accepted_declaration: true, email: old_email) }

    before do
      configure_requests_for_submit_domain
      visit "/sign-in"
      fill_in_credentials

      expect(page).to have_css("h1", text: "Check your phone")
      fill_in "Enter security code", with: "#{otp_code} "
      click_on "Continue"

      click_on "Your account"
      expect_to_be_on_my_account_page

      wait_for = SecondaryAuthentication::TIMEOUTS[SecondaryAuthentication::CHANGE_EMAIL_ADDRESS]
      travel_to((wait_for + 1).seconds.from_now)

      click_on "Change email address"
      expect(page).to have_css("h1", text: "Check your phone")
      fill_in "Enter security code", with: "#{otp_code} "
      click_on "Continue"
    end

    context "when the password change is fine" do
      it "changes password properly" do
        fill_in "Password", with: user.password
        fill_in "New email", with: "new@example.org"
        click_on "Continue"

        expect_to_be_on_my_account_page
        expect(page).to have_text(/A message with a confirmation link has been sent to your email address/)
        email = delivered_emails.first
        expect(email.recipient).to eq "new@example.org"

        confirm_url = email.personalization[:verify_email_url]
        expect(confirm_url).to include("/my_account/email/confirm?confirmation_token=")

        visit confirm_url

        expect_to_be_on_my_account_page

        email = delivered_emails.last
        expect(email.recipient).to eq old_email
        expect(email.personalization[:old_email_address]).to eq old_email
        expect(email.personalization[:new_email_address]).to eq "new@example.org"

        expect(page).to have_text(/Email changed successfully/)
        expect(user.reload.email).to eq("new@example.org")
      end
    end

    context "when the update cant be done" do
      it "does not get updated when password is wrong" do
        fill_in "Password", with: "user.password"
        fill_in "New email", with: "new@example.org"
        click_on "Continue"

        expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
        expect(page).to have_link("Password is incorrect", href: "#password")
      end

      it "does not get updated when new email is incorrect" do
        fill_in "Password", with: user.password
        fill_in "New email", with: "new@example"
        click_on "Continue"

        expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
        expect(page).to have_link("", href: "#new_email")
      end

      context "when confirmation cannot be done" do
        before do
          fill_in "Password", with: user.password
          fill_in "New email", with: "new@example.org"
          click_on "Continue"

          expect_to_be_on_my_account_page
          expect(page).to have_text(/A message with a confirmation link has been sent to your email address/)
          email = delivered_emails.last
          expect(email.recipient).to eq "new@example.org"

          confirm_url = email.personalization[:verify_email_url]
          expect(confirm_url).to include("/my_account/email/confirm?confirmation_token=")
        end

        context "when confirmation token is invalid" do
          it "displays proper message" do
            visit confirm_my_account_email_path(confirmation_token: "user.new_email_confirmation_token")

            expect_to_be_on_my_account_page
            expect(page).to have_text(/Email can not be changed, confirmation token is incorrect. Please try again./)
            expect(user.reload.email).not_to eq("new@example.org")
          end
        end

        context "when confirmation token is invalid" do
          it "displays proper message" do
            email = delivered_emails.last
            confirm_url = email.personalization[:verify_email_url]
            travel_to((User::NEW_EMAIL_TOKEN_VALID_FOR + 1).seconds.from_now)

            visit confirm_url

            fill_in "Enter security code", with: "#{otp_code} "
            click_on "Continue"

            expect_to_be_on_my_account_page
            expect(page).to have_text(/Email can not be changed, confirmation token is incorrect. Please try again./)
            expect(user.reload.email).not_to eq("new@example.org")
          end
        end
      end
    end
  end
end
