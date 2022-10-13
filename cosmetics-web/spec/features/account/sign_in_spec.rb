require "rails_helper"

RSpec.feature "Signing in as a user", :with_2fa, :with_stubbed_mailer, :with_stubbed_notify, type: :feature do
  shared_examples "sign up" do
    scenario "user tries to sign in with email address that does not belong to any user" do
      visit "/sign-in"

      expect_back_link_to("/")

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

      expect(page).to have_css(".govuk-error-summary__list", text: "Enter an email address in the correct format, like name@example.com")
      expect(page).to have_css(".govuk-error-message", text: "Enter an email address in the correct format, like name@example.com")
    end

    scenario "user leaves email and password fields empty" do
      visit "/sign-in"

      fill_in "Email address", with: " "
      fill_in "Password", with: " "
      click_button "Continue"

      expect(page).to have_css(".govuk-error-message", text: "Enter an email address")
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
    before do
      configure_requests_for_submit_domain
    end

    describe "for user with both app and sms secondary authentication", :with_2fa, :with_2fa_app do
      let(:user) { create(:submit_user, :with_all_secondary_authentication_methods, has_accepted_declaration: false) }

      scenario "user signs in selecting app authentication" do
        visit "/sign-in"
        fill_in_credentials
        select_secondary_authentication_app

        expect_to_be_on_secondary_authentication_app_page
        complete_secondary_authentication_app

        expect(page).to have_current_path("/declaration?redirect_path=%2Fdashboard")
        expect(page).to have_css("h1", text: "Responsible Person Declaration")
        click_button "I confirm"

        expect(page).to have_css("h1", text: "Are you or your organisation a UK Responsible Person?")
      end

      scenario "user signs in selecting sms authentication" do
        visit "/sign-in"
        fill_in_credentials
        select_secondary_authentication_sms

        expect_to_be_on_secondary_authentication_sms_page
        expect(page).to have_link("Back", href: "/two-factor/method")
        expect_back_link_to("/two-factor/method")
        complete_secondary_authentication_sms_with("#{otp_code} ")

        expect(page).to have_current_path("/declaration?redirect_path=%2Fdashboard")
        expect(page).to have_css("h1", text: "Responsible Person Declaration")
        click_button "I confirm"

        expect(page).to have_css("h1", text: "Are you or your organisation a UK Responsible Person?")
      end
    end

    describe "for user with app secondary authentication", :with_2fa_app do
      let(:user) { create(:submit_user, :with_app_secondary_authentication, has_accepted_declaration: false) }

      scenario "user signs in for first time" do
        visit "/sign-in"
        fill_in_credentials

        expect_to_be_on_secondary_authentication_app_page
        expect(page).not_to have_link("Back", href: "/two-factor/method")
        complete_secondary_authentication_app

        expect(page).to have_current_path("/declaration?redirect_path=%2Fdashboard")
        expect(page).to have_css("h1", text: "Responsible Person Declaration")
        click_button "I confirm"

        expect(page).to have_css("h1", text: "Are you or your organisation a UK Responsible Person?")
      end

      scenario "user attempts to sign in with wrong two factor authentication code" do
        visit "/sign-in"
        fill_in_credentials

        expect_to_be_on_secondary_authentication_app_page
        complete_secondary_authentication_app("111111")

        expect_to_be_on_secondary_authentication_app_page
        expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
        expect(page).to have_css("#otp_code-error", text: "Error: Incorrect access code")
      end
    end

    describe "for user with sms secondary authentication", :with_2fa do
      let(:user) { create(:submit_user, :with_sms_secondary_authentication, has_accepted_declaration: false) }

      scenario "user signs in for first time" do
        visit "/sign-in"
        fill_in_credentials

        expect_to_be_on_secondary_authentication_sms_page
        expect(page).not_to have_link("Back", href: "/two-factor/method")
        complete_secondary_authentication_sms_with("#{otp_code} ")

        expect(page).to have_current_path("/declaration?redirect_path=%2Fdashboard")
        expect(page).to have_css("h1", text: "Responsible Person Declaration")
        click_button "I confirm"

        expect(page).to have_css("h1", text: "Are you or your organisation a UK Responsible Person?")
      end

      scenario "user signs out when required to fill two factor authentication code" do
        visit "/sign-in"
        fill_in_credentials

        expect_to_be_on_secondary_authentication_sms_page

        within(".govuk-header__navigation") do
          click_link("Sign out")
        end

        expect(page).to have_css("h1", text: "Submit cosmetic product notifications")
        expect(page).to have_link("Sign in")
      end

      scenario "user attempts to sign in with wrong two factor authentication code" do
        visit "/sign-in"
        fill_in_credentials

        expect_to_be_on_secondary_authentication_sms_page
        wrong_code = otp_code.sub(/[0-9]/) { |x| x == "0" ? "1" : x.to_i - 1 }
        complete_secondary_authentication_sms_with(wrong_code)

        expect_to_be_on_secondary_authentication_sms_page
        expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
        expect(page).to have_css("#otp_code-error", text: "Error: Incorrect security code")
      end

      scenario "user signs in with correct secondary authentication code after requesting a second code" do
        allow(SecureRandom).to receive(:random_number).and_return(12_345, 54_321)

        visit "/sign-in"
        fill_in_credentials

        expect_user_to_have_received_sms_code("12345")

        expect_to_be_on_secondary_authentication_sms_page

        click_link "Not received a text message?"

        expect_to_be_on_resend_secondary_authentication_page

        click_button "Resend security code"

        expect_user_to_have_received_sms_code("54321")

        expect_to_be_on_secondary_authentication_sms_page
        complete_secondary_authentication_sms_with(otp_code)

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

          expect_to_be_on_secondary_authentication_sms_page

          fill_in "Enter security code", with: otp_code
          click_on "Continue"

          fill_in_credentials

          expect(page).to have_css("h1", text: "Responsible Person Declaration")
          expect(page).to have_link("Sign out")
        end

        scenario "user tries to use unlock link when logged in as different user" do
          user2 = create(:submit_user, :with_sms_secondary_authentication, has_accepted_declaration: false)
          user2.lock_access!

          visit "/sign-in"
          fill_in_credentials
          complete_secondary_authentication_sms_with(otp_code)

          expect(page).to have_css("h1", text: "Responsible Person Declaration")

          visit unlock_path
          expect_to_be_on_secondary_authentication_sms_page
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

          expect_to_be_on_secondary_authentication_sms_page
          complete_secondary_authentication_sms_with(otp_code)

          expect(page).to have_css("h1", text: "Create a new password")
        end
      end

      include_examples "sign up"
    end
  end

  describe "for search" do
    before do
      configure_requests_for_search_domain
    end

    describe "for user with both app and sms secondary authentication", :with_2fa, :with_2fa_app do
      let(:user) { create(:poison_centre_user, :with_all_secondary_authentication_methods, has_accepted_declaration: true) }

      scenario "user signs in selecting app authentication" do
        visit "/sign-in"
        fill_in_credentials
        select_secondary_authentication_app

        expect_to_be_on_secondary_authentication_app_page
        complete_secondary_authentication_app

        expect(page).to have_current_path("/notifications")
        expect(page).to have_css("h1", text: "Search cosmetic products")
      end

      scenario "user signs in selecting sms authentication" do
        visit "/sign-in"
        fill_in_credentials
        select_secondary_authentication_sms

        expect_to_be_on_secondary_authentication_sms_page
        complete_secondary_authentication_sms_with("#{otp_code} ")

        expect(page).to have_current_path("/notifications")

        expect(page).to have_css("h1", text: "Search cosmetic products")
      end
    end

    describe "for user with app secondary authentication", :with_2fa_app do
      let(:user) { create(:poison_centre_user, :with_app_secondary_authentication, has_accepted_declaration: true) }

      scenario "user signs in for first time" do
        visit "/sign-in"
        fill_in_credentials

        expect_to_be_on_secondary_authentication_app_page
        complete_secondary_authentication_app

        expect(page).to have_current_path("/notifications")
        expect(page).to have_css("h1", text: "Search cosmetic products")
      end

      scenario "user attempts to sign in with wrong two factor authentication code" do
        visit "/sign-in"
        fill_in_credentials

        expect_to_be_on_secondary_authentication_app_page

        fill_in "Access code", with: "111111"
        click_on "Continue"

        expect_to_be_on_secondary_authentication_app_page
        expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
        expect(page).to have_css("#otp_code-error", text: "Error: Incorrect access code")
      end
    end

    describe "for user with sms secondary authentication", :with_2fa do
      let(:user) { create(:poison_centre_user, :with_sms_secondary_authentication, has_accepted_declaration: true) }

      scenario "user signs in for first time" do
        visit "/sign-in"
        fill_in_credentials

        expect_to_be_on_secondary_authentication_sms_page
        complete_secondary_authentication_sms_with("#{otp_code} ")

        expect(page).to have_current_path("/notifications")

        expect(page).to have_css("h1", text: "Search cosmetic products")
      end

      scenario "user signs out when required to fill two factor authentication code" do
        visit "/sign-in"
        fill_in_credentials

        expect_to_be_on_secondary_authentication_sms_page

        within(".govuk-header__navigation") do
          click_link("Sign out")
        end

        expect(page).to have_css("h1", text: "Cosmetic product search")
        expect(page).to have_link("Sign in")
      end

      scenario "user attempts to sign in with wrong two factor authentication code" do
        visit "/sign-in"
        fill_in_credentials

        expect_to_be_on_secondary_authentication_sms_page
        wrong_code = otp_code.sub(/[0-9]/) { |x| x == "0" ? "1" : x.to_i - 1 }
        complete_secondary_authentication_sms_with(wrong_code)

        expect_to_be_on_secondary_authentication_sms_page
        expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
        expect(page).to have_css("#otp_code-error", text: "Error: Incorrect security code")
      end

      scenario "user signs in with correct secondary authentication code after requesting a second code" do
        allow(SecureRandom).to receive(:random_number).and_return(12_345, 54_321)

        visit "/sign-in"
        fill_in_credentials

        expect_user_to_have_received_sms_code("12345")

        expect_to_be_on_secondary_authentication_sms_page

        click_link "Not received a text message?"

        expect_to_be_on_resend_secondary_authentication_page

        click_button "Resend security code"

        expect_user_to_have_received_sms_code("54321")

        expect_to_be_on_secondary_authentication_sms_page
        complete_secondary_authentication_sms_with(otp_code)

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

          expect_to_be_on_secondary_authentication_sms_page
          complete_secondary_authentication_sms_with(otp_code)

          fill_in_credentials

          expect(page).to have_css("h1", text: "Search cosmetic products")
          expect(page).to have_link("Sign out")
        end

        scenario "user tries to use unlock link when logged in as different user" do
          user2 = create(:poison_centre_user, :with_sms_secondary_authentication, has_accepted_declaration: false)
          user2.lock_access!

          visit "/sign-in"
          fill_in_credentials
          complete_secondary_authentication_sms_with(otp_code)

          expect(page).to have_css("h1", text: "Search cosmetic products")

          visit unlock_path
          expect_to_be_on_secondary_authentication_sms_page
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

          expect_to_be_on_secondary_authentication_sms_page
          complete_secondary_authentication_sms_with(otp_code)

          expect(page).to have_css("h1", text: "Create a new password")
        end
      end

      include_examples "sign up"
    end
  end
end
