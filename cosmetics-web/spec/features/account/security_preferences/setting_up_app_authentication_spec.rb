require "rails_helper"

RSpec.feature "Setting up app authentication", :with_2fa, :with_2fa_app, :with_stubbed_notify, type: :feature do
  let(:responsible_person) { user.responsible_persons.first }

  before do
    configure_requests_for_submit_domain
  end

  def force_2fa_for_app_setup
    wait_for = SecondaryAuthentication::Operations::TIMEOUTS[SecondaryAuthentication::Operations::SETUP_APP_AUTHENTICATION]
    travel_to((wait_for + 1).seconds.from_now)
  end

  feature "user has no app authentication configured" do
    let(:user) do
      create(:submit_user, :with_responsible_person, :with_sms_secondary_authentication, has_accepted_declaration: true)
    end

    scenario "user sets app authentication" do
      # User visits its account
      visit "/sign-in"
      fill_in_credentials

      expect_to_be_on_secondary_authentication_sms_page
      expect_user_to_have_received_sms_code(otp_code)
      complete_secondary_authentication_sms_with(otp_code)

      expect_to_be_on__your_cosmetic_products_page
      click_link("Your account")

      # User attempts to set app as secondary authentication method
      expect_to_be_on_my_account_page
      expect(page).to have_summary_item(key: "Authenticator app", value: "")
      force_2fa_for_app_setup
      click_on "Add authenticator app"

      # User needs to go through its current 2FA method (sms) prior to change the 2FA methods.
      expect_to_be_on_secondary_authentication_sms_page
      expect_user_to_have_received_sms_code(otp_code)
      complete_secondary_authentication_sms_with(otp_code)

      expect(page).to have_css("h1", text: "Set up your authenticator app")
      expect_back_link_to_my_account_page
      # Update gets rejected when the password is wrong
      fill_in "Password", with: "wrongPassword"
      fill_in "Enter the access code", with: "123456"
      click_on "Continue"

      expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
      expect(page).to have_link("Password is incorrect", href: "#password")

      # Update gets rejected when the app access code is empty
      fill_in "Password", with: user.password
      fill_in "Enter the access code", with: ""
      click_on "Continue"

      expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
      expect(page).to have_link("Enter an access code", href: "#app_authentication_code")

      # Update gets rejected when the app access code is invalid
      fill_in "Password", with: user.password
      fill_in "Enter the access code", with: "wrongCode"
      click_on "Continue"

      expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
      expect(page).to have_link("Access code is incorrect", href: "#app_authentication_code")

      # User provides the right authentication code and password
      fill_in "Password", with: user.password
      fill_in "Enter the access code", with: "123456"
      click_on "Continue"

      # 2FA method successfully updated
      expect_to_be_on_my_account_page
      expect(page).to have_text(/Authenticator app set successfully/)
      expect(page).to have_summary_item(key: "Authenticator app", value: "Authenticator app is set")

      # Confirm App is now an available option for 2FA
      force_2fa_for_app_setup
      click_on "Update authenticator app"
      expect_to_be_on_secondary_authentication_method_selection_page
    end
  end

  feature "user has set previously their app authentication" do
    let(:user) do
      create(:submit_user, :with_responsible_person, :with_app_secondary_authentication, has_accepted_declaration: true)
    end

    scenario "user updates app authentication" do
      original_totp_secret_key = user.totp_secret_key

      # User visits its account
      visit "/sign-in"
      fill_in_credentials

      expect_to_be_on_secondary_authentication_app_page
      complete_secondary_authentication_app

      expect_to_be_on__your_cosmetic_products_page
      click_link("Your account")

      # User attempts to update the authenticator app setup
      expect(page).to have_summary_item(key: "Authenticator app", value: "Authenticator app is set")
      force_2fa_for_app_setup
      click_on "Update authenticator app"

      # User needs to go through its current app access code prior to the update
      expect_to_be_on_secondary_authentication_app_page
      complete_secondary_authentication_app

      expect(page).to have_css("h1", text: "Update your authenticator app")
      expect_back_link_to_my_account_page
      # Update gets rejected when the password is wrong
      fill_in "Password", with: "wrongPassword"
      fill_in "Enter the access code", with: "123456"
      click_on "Continue"

      expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
      expect(page).to have_link("Password is incorrect", href: "#password")

      # Update gets rejected when the app access code is empty
      fill_in "Password", with: user.password
      fill_in "Enter the access code", with: ""
      click_on "Continue"

      expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
      expect(page).to have_link("Enter an access code", href: "#app_authentication_code")

      # Update gets rejected when the app access code is invalid
      fill_in "Password", with: user.password
      fill_in "Enter the access code", with: "wrongCode"
      click_on "Continue"

      expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
      expect(page).to have_link("Access code is incorrect", href: "#app_authentication_code")

      # User provides the right authentication code and password
      fill_in "Password", with: user.password
      fill_in "Enter the access code", with: "123456"
      click_on "Continue"

      # 2FA method successfully updated
      expect_to_be_on_my_account_page
      expect(page).to have_text(/Authenticator app set successfully/)
      expect(page).to have_summary_item(key: "Authenticator app", value: "Authenticator app is set")

      # User authenticator app configuration has changed
      expect(user.reload.totp_secret_key).not_to eq(original_totp_secret_key)
    end
  end

  feature "user has set previously both text and app authentication" do
    let(:user) do
      create(:submit_user, :with_responsible_person, :with_all_secondary_authentication_methods, has_accepted_declaration: true)
    end

    scenario "user updates text message authentication" do
      original_totp_secret_key = user.totp_secret_key

      # User visits its account
      visit "/sign-in"
      fill_in_credentials

      expect_to_be_on_secondary_authentication_method_selection_page
      select_secondary_authentication_app
      expect_to_be_on_secondary_authentication_app_page
      complete_secondary_authentication_app

      expect_to_be_on__your_cosmetic_products_page
      click_link("Your account")

      # User attempts to update the authenticator app setup
      expect(page).to have_summary_item(key: "Authenticator app", value: "Authenticator app is set")
      force_2fa_for_app_setup
      click_on "Update authenticator app"

      # User needs to select a 2FA method and complete the 2FA check prior to the update
      expect_to_be_on_secondary_authentication_method_selection_page
      select_secondary_authentication_sms
      expect_to_be_on_secondary_authentication_sms_page
      complete_secondary_authentication_sms_with(otp_code)

      expect(page).to have_css("h1", text: "Update your authenticator app")
      expect_back_link_to_my_account_page
      # Update gets rejected when the password is wrong
      fill_in "Password", with: "wrongPassword"
      fill_in "Enter the access code", with: "123456"
      click_on "Continue"

      expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
      expect(page).to have_link("Password is incorrect", href: "#password")

      # Update gets rejected when the app access code is empty
      fill_in "Password", with: user.password
      fill_in "Enter the access code", with: ""
      click_on "Continue"

      expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
      expect(page).to have_link("Enter an access code", href: "#app_authentication_code")

      # Update gets rejected when the app access code is invalid
      fill_in "Password", with: user.password
      fill_in "Enter the access code", with: "wrongCode"
      click_on "Continue"

      expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
      expect(page).to have_link("Access code is incorrect", href: "#app_authentication_code")

      # User provides the right authentication code and password
      fill_in "Password", with: user.password
      fill_in "Enter the access code", with: "123456"
      click_on "Continue"

      # 2FA method successfully updated
      expect_to_be_on_my_account_page
      expect(page).to have_text(/Authenticator app set successfully/)
      expect(page).to have_summary_item(key: "Authenticator app", value: "Authenticator app is set")

      # User authenticator app configuration has changed
      expect(user.reload.totp_secret_key).not_to eq(original_totp_secret_key)
    end
  end
end
