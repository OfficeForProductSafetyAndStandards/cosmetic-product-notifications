require 'rails_helper'

RSpec.describe "Changing email address", :with_2fa, :with_stubbed_mailer, :with_stubbed_notify, type: :feature do
  before do
    configure_requests_for_search_domain
  end

  def fill_in_credentials(password_override: nil)
    fill_in "Email address", with: user.email
    if password_override
      fill_in "Password", with: password_override
    else
      fill_in "Password", with: user.password
    end
    click_on "Continue"
  end

  def expect_user_to_have_received_sms_code(code)
    expect(notify_stub).to have_received(:send_sms).with(
      hash_including(phone_number: user.mobile_number, personalisation: { code: code }),
    )
  end

  def expect_to_be_on_secondary_authentication_page
    expect(page).to have_current_path(/\/two-factor/)
    expect(page).to have_h1("Check your phone")
  end

  def expect_to_be_on_resend_secondary_authentication_page
    expect(page).to have_current_path("/text-not-received")
    expect(page).to have_h1("Resend security code")
  end

  def otp_code
    user.reload.direct_otp
  end

  def expect_to_be_on_my_account_page
    expect(page).to have_current_path(/\/my_account/)
  end

  let(:user) { create(:poison_centre_user, has_accepted_declaration: true) }

  before do
    visit "/sign-in"
    fill_in_credentials

    expect(page).to have_css("h1", text: "Check your phone")
    fill_in "Enter security code", with: "#{otp_code} "
    click_on "Continue"

    click_on "Your account"
    expect_to_be_on_my_account_page

    wait_for = SecondaryAuthentication::TIMEOUTS[SecondaryAuthentication::CHANGE_EMAIL_ADDRESS]
    travel_to (wait_for + 1).seconds.from_now

    click_on "Change email address"
    expect(page).to have_css("h1", text: "Check your phone")
    fill_in "Enter security code", with: "#{otp_code} "
    click_on "Continue"
  end

  context "when the password change is fine" do
    it "changes password properly" do
      fill_in "Password", with: user.password
      fill_in "New email", with: "new@example.org"
      click_on "Save"

      expect_to_be_on_my_account_page
      expect(page).to have_text(/Confirmation email sent. Please follow instructions from email/)
      email = delivered_emails.last
      expect(email.recipient).to eq "new@example.org"

      confirm_url = email.personalization[:verify_email_url]
      expect(confirm_url).to include("/my_account/email/confirm?confirmation_token=")

      visit confirm_url

      expect_to_be_on_my_account_page
      expect(page).to have_text(/Email changed successfully/)
      expect(user.reload.email).to eq("new@example.org")
    end
  end

  context "when the update cant be done" do
    it "does not get updated when password is wrong" do
      fill_in "Password", with: "user.password"
      fill_in "New email", with: "new@example.org"
      click_on "Save"

      expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
      expect(page).to have_link("Password is incorrect", href: "#password")
    end

    it "does not get updated when new email is incorrect" do
      fill_in "Password", with: user.password
      fill_in "New email", with: "new@example"
      click_on "Save"

      expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
      expect(page).to have_link("", href: "#new_email")
    end

    context "when confirmation cannot be done" do
      before do
        fill_in "Password", with: user.password
        fill_in "New email", with: "new@example.org"
        click_on "Save"

        expect_to_be_on_my_account_page
        expect(page).to have_text(/Confirmation email sent. Please follow instructions from email/)
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
          travel_to (User::NEW_EMAIL_TOKEN_VALID_FOR + 1).seconds.from_now

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
