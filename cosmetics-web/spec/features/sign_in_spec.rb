require "rails_helper"

RSpec.feature "Signing in as a user", :with_2fa, :with_stubbed_mailer, :with_stubbed_notify, type: :feature do
  def fill_in_credentials(password_override: nil)
    fill_in "Email address", with: user.email
    if password_override
      fill_in "Password", with: password_override
    else
      fill_in "Password", with: user.password
    end
    click_on "Continue"
  end

  def expect_incorrect_email_or_password
    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link("Enter correct email address and password", href: "#email")
    expect(page).to have_css("span#email-error", text: "Error: Enter correct email address and password")
    expect(page).to have_css("span#password-error", text: "")

    expect(page).not_to have_link("Cases")
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

  shared_examples "sign up" do
    scenario "user tries to sign in with email address that does not belong to any user" do
      visit "/sign-in"

      fill_in "Email address", with: "notarealuser@example.com"
      fill_in "Password", with: "notarealpassword"
      click_button "Continue"

      expect_incorrect_email_or_password
    end

    scenario "user introduces wrong password" do
      visit "/sign-in"

      fill_in "Email address", with: user.email
      fill_in "Password", with: "passworD"
      click_button "Continue"

      expect_incorrect_email_or_password
    end

    scenario "user introduces email address with incorrect format" do
      visit "/sign-in"

      fill_in "Email address", with: "test.email"
      fill_in "Password", with: "password "
      click_button "Continue"

      expect(page).to have_css(".govuk-error-summary__list", text: "Enter your email address in the correct format, like name@example.com")
      expect(page).to have_css(".govuk-error-message", text: "Enter your email address in the correct format, like name@example.com")
    end

    scenario "user leaves email and password fields empty" do
      visit "/sign-in"

      fill_in "Email address", with: " "
      fill_in "Password", with: " "
      click_button "Continue"

      expect(page).to have_css(".govuk-error-message", text: "Enter your email address")
      expect(page).to have_css(".govuk-error-message", text: "Enter your password")
    end

    scenario "user leaves password field empty" do
      visit "/sign-in"

      fill_in "Email address", with: user.email
      fill_in "Password", with: " "
      click_button "Continue"

      expect(page).to have_css(".govuk-error-message", text: "Enter your password")
      expect(page).to have_css(".govuk-error-summary__list", text: "Enter your password")
    end
  end

  describe "for submit" do
    let(:user) { create(:submit_user, has_accepted_declaration: false) }

    before do
      configure_requests_for_submit_domain
    end

    scenario "user signs in for first time" do
      visit "/sign-in"
      fill_in_credentials

      expect(page).to have_css("h1", text: "Check your phone")
      fill_in "Enter security code", with: "#{otp_code} "
      click_on "Continue"

      expect(page).to have_current_path("/declaration?redirect_path=%2Fdashboard")
      expect(page).to have_css("h1", text: "Responsible Person Declaration")
      click_button "I confirm"

      expect(page).to have_css("h1", text: "Are you or your organisation a UK Responsible Person?")
    end

    scenario "user signs out when required to fill two factor authentication code" do
      visit "/sign-in"
      fill_in_credentials

      expect(page).to have_css("h1", text: "Check your phone")

      within(".govuk-header__navigation") do
        click_link("Sign out")
      end

      expect(page).to have_css("h1", text: "Submit cosmetic product notifications")
      expect(page).to have_link("Sign in")
    end

    scenario "user attempts to sign in with wrong two factor authentication code" do
      visit "/sign-in"
      fill_in_credentials

      expect(page).to have_css("h1", text: "Check your phone")

      fill_in "Enter security code", with: otp_code.reverse
      click_on "Continue"

      expect(page).to have_css("h1", text: "Check your phone")
      expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
      expect(page).to have_css("#otp_code-error", text: "Error: Incorrect security code")
    end

    scenario "user signs in with correct secondary authentication code after requesting a second code" do
      allow(SecureRandom).to receive(:random_number).and_return(12_345, 54_321)

      visit "/sign-in"
      fill_in_credentials

      expect_user_to_have_received_sms_code("12345")

      expect_to_be_on_secondary_authentication_page

      click_link "Not received a text message?"

      expect_to_be_on_resend_secondary_authentication_page

      click_button "Resend security code"

      expect_user_to_have_received_sms_code("54321")

      expect_to_be_on_secondary_authentication_page

      fill_in "Enter security code", with: otp_code
      click_button "Continue"

      expect(page).to have_css("h1", text: "Responsible Person Declaration")
      expect(page).to have_link("Sign out", href: destroy_submit_user_session_path)
    end

    context "when using wrong credentials over and over again" do
      let(:unlock_email) { delivered_emails.last }
      let(:unlock_path) { unlock_email.personalization_path(:unlock_user_url_token) }

      scenario "user gets locked and uses the unlock link received by email" do
        Devise.maximum_attempts.times do
          visit "/sign-in"
          fill_in_credentials(password_override: "XXX")
        end

        expect(page).to have_css("p", text: "We’ve locked this account to protect its security.")

        visit unlock_path

        expect(page).to have_css("h1", text: "Check your phone")

        fill_in "Enter security code", with: otp_code
        click_on "Continue"

        fill_in_credentials

        expect(page).to have_css("h1", text: "Responsible Person Declaration")
        expect(page).to have_link("Sign out")
      end

      scenario "user tries to use unlock link when logged in as different user" do
        user2 = create(:submit_user, has_accepted_declaration: false)
        user2.lock_access!

        visit "/sign-in"
        fill_in_credentials
        fill_in "Enter security code", with: otp_code
        click_on "Continue"

        expect(page).to have_css("h1", text: "Responsible Person Declaration")

        visit unlock_path
        expect(page).to have_css("h1", text: "Check your phone")
      end

      scenario "user follows an invalid unlock link" do
        visit "/unlock?unlock_token=wrong-token"
        expect(page).to have_css("h1", text: "Invalid link")
        expect(page.status_code).to eq(404)
      end

      scenario "locked user receives email with reset password link" do
        Devise.maximum_attempts.times do
          visit "/sign-in"
          fill_in_credentials(password_override: "XXX")
        end

        expect(page).to have_css("p", text: "We’ve locked this account to protect its security.")

        unlock_email = delivered_emails.last
        visit unlock_email.personalization_path(:edit_user_password_url_token)

        expect(page).to have_css("h1", text: "Check your phone")

        fill_in "Enter security code", with: otp_code
        click_on "Continue"

        expect(page).to have_css("h1", text: "Create a new password")
      end
    end

    include_examples "sign up"
  end

  describe "for search" do
    let(:user) { create(:poison_centre_user, has_accepted_declaration: true) }

    before do
      configure_requests_for_search_domain
    end

    scenario "user signs in for first time" do
      visit "/sign-in"
      fill_in_credentials

      expect(page).to have_css("h1", text: "Check your phone")
      fill_in "Enter security code", with: "#{otp_code} "
      click_on "Continue"

      expect(page).to have_current_path("/notifications")

      expect(page).to have_css("h1", text: "Search cosmetic products")
    end

    scenario "user signs out when required to fill two factor authentication code" do
      visit "/sign-in"
      fill_in_credentials

      expect(page).to have_css("h1", text: "Check your phone")

      within(".govuk-header__navigation") do
        click_link("Sign out")
      end

      expect(page).to have_css("h1", text: "Search for cosmetic products")
      expect(page).to have_link("Sign in")
    end

    scenario "user attempts to sign in with wrong two factor authentication code" do
      visit "/sign-in"
      fill_in_credentials

      expect(page).to have_css("h1", text: "Check your phone")

      fill_in "Enter security code", with: otp_code.reverse
      click_on "Continue"

      expect(page).to have_css("h1", text: "Check your phone")
      expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
      expect(page).to have_css("#otp_code-error", text: "Error: Incorrect security code")
    end

    scenario "user signs in with correct secondary authentication code after requesting a second code" do
      allow(SecureRandom).to receive(:random_number).and_return(12_345, 54_321)

      visit "/sign-in"
      fill_in_credentials

      expect_user_to_have_received_sms_code("12345")

      expect_to_be_on_secondary_authentication_page

      click_link "Not received a text message?"

      expect_to_be_on_resend_secondary_authentication_page

      click_button "Resend security code"

      expect_user_to_have_received_sms_code("54321")

      expect_to_be_on_secondary_authentication_page

      fill_in "Enter security code", with: otp_code
      click_button "Continue"

      expect(page).to have_css("h1", text: "Search cosmetic products")
      expect(page).to have_link("Sign out", href: destroy_search_user_session_path)
    end

    context "when using wrong credentials over and over again" do
      let(:unlock_email) { delivered_emails.last }
      let(:unlock_path) { unlock_email.personalization_path(:unlock_user_url_token) }

      scenario "user gets locked and uses the unlock link received by email" do
        Devise.maximum_attempts.times do
          visit "/sign-in"
          fill_in_credentials(password_override: "XXX")
        end

        expect(page).to have_css("p", text: "We’ve locked this account to protect its security.")

        visit unlock_path

        expect(page).to have_css("h1", text: "Check your phone")

        fill_in "Enter security code", with: otp_code
        click_on "Continue"

        fill_in_credentials

        expect(page).to have_css("h1", text: "Search cosmetic products")
        expect(page).to have_link("Sign out")
      end

      scenario "user tries to use unlock link when logged in as different user" do
        user2 = create(:poison_centre_user, has_accepted_declaration: false)
        user2.lock_access!

        visit "/sign-in"
        fill_in_credentials
        fill_in "Enter security code", with: otp_code
        click_on "Continue"

        expect(page).to have_css("h1", text: "Search cosmetic products")

        visit unlock_path
        expect(page).to have_css("h1", text: "Check your phone")
      end

      scenario "user follows an invalid unlock link" do
        visit "/unlock?unlock_token=wrong-token"
        expect(page).to have_css("h1", text: "Invalid link")
        expect(page.status_code).to eq(404)
      end

      scenario "locked user receives email with reset password link" do
        Devise.maximum_attempts.times do
          visit "/sign-in"
          fill_in_credentials(password_override: "XXX")
        end

        expect(page).to have_css("p", text: "We’ve locked this account to protect its security.")

        unlock_email = delivered_emails.last
        visit unlock_email.personalization_path(:edit_user_password_url_token)

        expect(page).to have_css("h1", text: "Check your phone")

        fill_in "Enter security code", with: otp_code
        click_on "Continue"

        expect(page).to have_css("h1", text: "Create a new password")
      end
    end

    include_examples "sign up"
  end
end
