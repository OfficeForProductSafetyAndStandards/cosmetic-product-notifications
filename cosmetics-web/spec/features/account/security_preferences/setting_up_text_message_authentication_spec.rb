require "rails_helper"

RSpec.feature "Setting up text message authentication", :with_2fa, :with_2fa_app, :with_stubbed_mailer, :with_stubbed_notify, type: :feature do
  let(:responsible_person) { user.responsible_persons.first }

  before do
    configure_requests_for_submit_domain
  end

  def force_2fa_for_mobile_number_change
    wait_for = SecondaryAuthentication::Operations::TIMEOUTS[SecondaryAuthentication::Operations::CHANGE_MOBILE_NUMBER]
    travel_to((wait_for + 1).seconds.from_now)
  end

  feature "user has no text message authentication" do
    let(:user) do
      create(:submit_user, :with_responsible_person, :with_app_secondary_authentication, has_accepted_declaration: true)
    end

    scenario "user sets text message authentication" do
      # User visits its account
      visit "/sign-in"
      fill_in_credentials

      expect_to_be_on_secondary_authentication_app_page
      complete_secondary_authentication_app

      expect_to_be_on__your_cosmetic_products_page
      click_link("Your account")

      # User attempts to set text message as secondary authentication method
      expect_to_be_on_my_account_page
      expect(page).to have_summary_item(key: "Text message", value: "")
      force_2fa_for_mobile_number_change
      click_on "Add text message"

      # User needs to go through its current 2FA method (APP) prior to change the 2FA methods.
      expect_to_be_on_secondary_authentication_app_page
      complete_secondary_authentication_app

      expect(page).to have_css("h1", text: "Set your mobile number")
      # Update gets rejected when the password is wrong
      fill_in "Password", with: "wrongPassword"
      fill_in "New mobile number", with: "07234234234"
      click_on "Continue"

      expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
      expect(page).to have_link("Password is incorrect", href: "#old_password")

      # Update gets rejected when the mobile number is empty
      fill_in "Password", with: user.password
      fill_in "New mobile number", with: ""
      click_on "Continue"

      expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
      expect(page).to have_link("Enter a mobile number, like 07700 900 982 or +44 7700 900 982", href: "#new_mobile_number")

      # Update gets rejected when the mobile number format is incorrect
      fill_in "Password", with: user.password
      fill_in "New mobile number", with: "12345678(wrong)9101112"
      click_on "Continue"

      expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
      expect(page).to have_link("Enter a mobile number, like 07700 900 982 or +44 7700 900 982", href: "#new_mobile_number")

      # User sets a correct mobile number and provides the right password
      fill_in "Password", with: user.password
      fill_in "New mobile number", with: "07234234234"
      click_on "Continue"

      # User needs to confirm its new mobile number through a SMS
      expect(page).to have_css("h1", text: "Check your phone")
      fill_in "Enter security code", with: "#{otp_code} "
      click_on "Continue"

      # 2FA method successfully updated
      expect_to_be_on_my_account_page
      expect(page).to have_text(/Mobile number set successfully/)
      expect(page).to have_summary_item(key: "Text message", value: "07234234234")

      # Confirm SMS is now an available option for 2FA
      force_2fa_for_mobile_number_change
      click_on "Update text message"
      expect_to_be_on_secondary_authentication_method_selection_page
    end
  end

  feature "user has set previously their text message authentication" do
    let(:user) do
      create(:submit_user, :with_responsible_person, :with_sms_secondary_authentication, has_accepted_declaration: true)
    end

    scenario "user updates text message authentication" do
      # User visits its account
      visit "/sign-in"
      fill_in_credentials

      expect_to_be_on_secondary_authentication_sms_page
      expect_user_to_have_received_sms_code(otp_code)
      complete_secondary_authentication_sms_with(otp_code)

      expect_to_be_on__your_cosmetic_products_page
      click_link("Your account")

      # User attempts to update the mobile number for 2FA with text message
      expect(page).to have_summary_item(key: "Text message", value: "07500 000 000")
      force_2fa_for_mobile_number_change
      click_on "Update text message"

      # User needs to go through its current 2FA method (SMS to the current mobile number) prior to update the mobile number
      expect_to_be_on_secondary_authentication_sms_page
      expect_user_to_have_received_sms_code(otp_code)
      complete_secondary_authentication_sms_with(otp_code)

      expect(page).to have_css("h1", text: "Change your mobile number")
      # Update gets rejected when the password is wrong
      fill_in "Password", with: "wrongPassword"
      fill_in "New mobile number", with: "07234234234"
      click_on "Continue"

      expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
      expect(page).to have_link("Password is incorrect", href: "#old_password")

      # Update gets rejected when the mobile number is empty
      fill_in "Password", with: user.password
      fill_in "New mobile number", with: ""
      click_on "Continue"

      expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
      expect(page).to have_link("Enter a mobile number, like 07700 900 982 or +44 7700 900 982", href: "#new_mobile_number")

      # Update gets rejected when the mobile number format is incorrect
      fill_in "Password", with: user.password
      fill_in "New mobile number", with: "12345678(wrong)9101112"
      click_on "Continue"

      expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
      expect(page).to have_link("Enter a mobile number, like 07700 900 982 or +44 7700 900 982", href: "#new_mobile_number")

      # User sets a correct mobile number and provides the right password
      expect(page).to have_css("h1", text: "Change your mobile number")
      fill_in "Password", with: user.password
      fill_in "New mobile number", with: "07234234234"
      click_on "Continue"

      # User needs to confirm its new mobile number through a SMS
      expect(page).to have_css("h1", text: "Check your phone")
      fill_in "Enter security code", with: "#{otp_code} "
      click_on "Continue"

      # 2FA method successfully updated
      expect_to_be_on_my_account_page
      expect(page).to have_text(/Mobile number changed successfully/)
      expect(page).to have_summary_item(key: "Text message", value: "07234234234")
    end
  end

  feature "user has set previously both text and app authentication" do
    let(:user) do
      create(:submit_user, :with_responsible_person, :with_all_secondary_authentication_methods, has_accepted_declaration: true)
    end

    scenario "user updates text message authentication" do
      # User visits its account
      visit "/sign-in"
      fill_in_credentials

      expect_to_be_on_secondary_authentication_method_selection_page
      select_secondary_authentication_sms
      expect_to_be_on_secondary_authentication_sms_page
      expect_user_to_have_received_sms_code(otp_code)
      complete_secondary_authentication_sms_with(otp_code)

      expect_to_be_on__your_cosmetic_products_page
      click_link("Your account")

      # User attempts to update the mobile number for 2FA with text message
      expect(page).to have_summary_item(key: "Text message", value: "07500 000 000")
      force_2fa_for_mobile_number_change
      click_on "Update text message"

      # User needs to select a 2FA method and complete the 2FA check prior to update the mobile number
      expect_to_be_on_secondary_authentication_method_selection_page
      select_secondary_authentication_app
      expect_to_be_on_secondary_authentication_app_page
      complete_secondary_authentication_app

      expect(page).to have_css("h1", text: "Change your mobile number")
      # Update gets rejected when the password is wrong
      fill_in "Password", with: "wrongPassword"
      fill_in "New mobile number", with: "07234234234"
      click_on "Continue"

      expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
      expect(page).to have_link("Password is incorrect", href: "#old_password")

      # Update gets rejected when the mobile number is empty
      fill_in "Password", with: user.password
      fill_in "New mobile number", with: ""
      click_on "Continue"

      expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
      expect(page).to have_link("Enter a mobile number, like 07700 900 982 or +44 7700 900 982", href: "#new_mobile_number")

      # Update gets rejected when the mobile number format is incorrect
      fill_in "Password", with: user.password
      fill_in "New mobile number", with: "12345678(wrong)9101112"
      click_on "Continue"

      expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
      expect(page).to have_link("Enter a mobile number, like 07700 900 982 or +44 7700 900 982", href: "#new_mobile_number")

      # User sets a correct mobile number and provides the right password
      expect(page).to have_css("h1", text: "Change your mobile number")
      fill_in "Password", with: user.password
      fill_in "New mobile number", with: "07234234234"
      click_on "Continue"

      # User needs to confirm its new mobile number through a SMS
      expect(page).to have_css("h1", text: "Check your phone")
      fill_in "Enter security code", with: "#{otp_code} "
      click_on "Continue"

      # 2FA method successfully updated
      expect_to_be_on_my_account_page
      expect(page).to have_text(/Mobile number changed successfully/)
      expect(page).to have_summary_item(key: "Text message", value: "07234234234")
    end
  end
end
