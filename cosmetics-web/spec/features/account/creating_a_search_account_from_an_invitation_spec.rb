require "rails_helper"
require "support/feature_helpers"

RSpec.feature "Creating a Search account from an invitation", :with_stubbed_mailer, :with_stubbed_notify, :with_2fa, :with_2fa_app, type: :feature do
  let!(:invited_user) { InviteSearchUser.call(email: "john.doe@example.com", name: "John Doe", role: :poison_centre).user }
  let(:existing_user) { create(:poison_centre_user, :with_sms_secondary_authentication) }

  before do
    configure_requests_for_search_domain
  end

  scenario "Creating a Search account from an invitation" do
    email = delivered_emails.last
    invite_url = email.personalization[:invitation_url]
    visit invite_url

    expect_to_be_on_complete_registration_page

    # First attempt not selecting a secondary authentication method
    fill_in_account_details_with(full_name: "Bob Jones", password: "testpassword123@")
    click_button "Continue"

    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link("Select how to get an access code", href: "#app_authentication")

    # Second attempt selecting both methods but introducing wrong app authentication code
    fill_in_account_details_with(full_name: "Bob Jones",
                                 password: "testpassword123@",
                                 mobile_number: "07731123345",
                                 app_code: "000000")
    click_button "Continue"

    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link("Enter a correct code", href: "#app_authentication_code")
    expect(page).to have_css("p#app_authentication_code-error", text: "Enter a correct code")

    # Third attempt introducing the correct app authentication code
    fill_in_account_details_with(full_name: "Bob Jones",
                                 password: "testpassword123@",
                                 mobile_number: "07731123345",
                                 app_code: correct_app_code)
    click_button "Continue"

    expect_to_be_on_secondary_authentication_sms_page
    complete_secondary_authentication_sms_with(otp_code)

    expect_to_be_on_secondary_authentication_recovery_codes_setup_page
    expect(page).to have_css("div.opss-recovery-codes", exact_text: recovery_codes_to_string(invited_user.reload.secondary_authentication_recovery_codes))
    click_link "Continue"

    expect_to_be_on_declaration_page
    click_button "I accept"
    expect_to_be_signed_in_as_search_user

    # Now sign out and use those credentials to sign back in
    click_button "Sign out"

    expect_to_be_on_the_search_homepage

    within("div.govuk-header__content") do
      click_link "Sign in"
    end

    fill_in "Email address", with: invited_user.email
    fill_in "Password", with: "testpassword123@"
    click_on "Continue"

    # Skips 2FA as cookie was set to not require
    # 2FA for 7 days.

    expect_to_be_signed_in_as_search_user
  end

  scenario "Creating an account from an invitation when signed in as another user" do
    sign_in existing_user

    visit "/users/#{invited_user.id}/complete-registration?invitation=#{invited_user.invitation_token}"

    expect_to_be_on_signed_in_as_another_user_page

    click_button "Create a new account"

    expect_to_be_on_complete_registration_page

    fill_in_account_details_with full_name: "Bob Jones", mobile_number: "07731123345", password: "testpassword123@"

    click_button "Continue"

    expect_to_be_on_secondary_authentication_sms_page

    fill_in "Enter security code", with: otp_code
    click_on "Continue"

    expect_to_be_on_secondary_authentication_recovery_codes_setup_page
    expect(page).to have_css("div.opss-recovery-codes", exact_text: recovery_codes_to_string(invited_user.reload.secondary_authentication_recovery_codes))
    click_link "Continue"

    expect_to_be_on_declaration_page
    click_button "I accept"
    expect_to_be_signed_in_as_search_user
  end

  scenario "Creating a Search account from an invitation selecting both text and app methods but then moving back to only use the app" do
    email = delivered_emails.last
    invite_url = email.personalization[:invitation_url]
    visit invite_url

    expect_to_be_on_complete_registration_page

    # First attempt not selecting a secondary authentication method
    fill_in_account_details_with(full_name: "Bob Jones", password: "testpassword123@")
    click_button "Continue"

    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link("Select how to get an access code", href: "#app_authentication")

    # Second attempt selecting both methods but introducing wrong app authentication code
    fill_in_account_details_with(full_name: "Bob Jones",
                                 password: "testpassword123@",
                                 mobile_number: "07731123345",
                                 app_code: "000000")
    click_button "Continue"

    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link("Enter a correct code", href: "#app_authentication_code")
    expect(page).to have_css("p#app_authentication_code-error", text: "Enter a correct code")

    # Third attempt introducing the correct app authentication code
    fill_in_account_details_with(full_name: "Bob Jones",
                                 password: "testpassword123@",
                                 mobile_number: "07731123345",
                                 app_code: correct_app_code)
    click_button "Continue"

    # User decides to not use text authentication and goes back to change complete registration page options
    expect_to_be_on_secondary_authentication_sms_page
    expect_back_link_to_complete_registration_page
    click_button("Back")

    expect_to_be_on_complete_registration_page
    expect(page).to have_checked_field("Authenticator app for smartphone or tablet")
    expect(page).to have_checked_field("Text message")
    expect(page).to have_field("Mobile number", with: "07731123345")

    # Finally user unchecks the text message authentication and re-submits the form
    uncheck "Text message"
    fill_in_account_details_with(full_name: "Bob Jones",
                                 password: "testpassword123@",
                                 app_code: correct_app_code)
    click_button "Continue"

    expect_to_be_on_secondary_authentication_recovery_codes_setup_page
    expect(page).to have_css("div.opss-recovery-codes", exact_text: recovery_codes_to_string(invited_user.reload.secondary_authentication_recovery_codes))
    click_link "Continue"

    expect_to_be_on_declaration_page
    click_button "I accept"
    expect_to_be_signed_in_as_search_user

    # Now sign out and use those credentials to sign back in
    click_button "Sign out"

    expect_to_be_on_the_search_homepage

    within("div.govuk-header__content") do
      click_link "Sign in"
    end

    fill_in "Email address", with: invited_user.email
    fill_in "Password", with: "testpassword123@"
    click_on "Continue"

    # Skips 2FA as cookie was set to not require
    # 2FA for 7 days.

    expect_to_be_signed_in_as_search_user
  end

  # TODO
  # context "when a previous registration was abandoned before verifying mobile number" do
  #   let(:invited_user) do
  #     create(
  #       :user,
  #       :invited,
  #       name: "Bob Jones",
  #       mobile_number: "07700 900 982",
  #       mobile_number_verified: false
  #     )
  #   end

  #   scenario "it shouldn't show values entered previously" do
  #     visit "/users/#{invited_user.id}/complete-registration?invitation=#{invited_user.invitation_token}"

  #     expect_to_be_on_complete_registration_page

  #     # Form should NOT contain values from previous abandoned registration
  #     expect(find_field("Full name").value).to eq ""
  #     expect(find_field("Mobile number").value).to eq ""

  #     # Deliberately leave password blank
  #     fill_in_account_details_with full_name: "Bob Jones", mobile_number: "07731123345", password: ""

  #     click_button "Continue"

  #     # Form SHOULD now contain pre-filled values from previous submission
  #     expect(find_field("Full name").value).to eq("Bob Jones")
  #     expect(find_field("Mobile number").value).to eq("07731123345")

  #     # Now add a password
  #     fill_in "Password", with: "testpassword123@"

  #     click_button "Continue"

  #     expect_to_be_on_secondary_authentication_sms_page

  #     fill_in "Enter security code", with: otp_code
  #     click_on "Continue"

  #     expect_to_be_on_declaration_page
  #     expect_to_be_signed_in_as_search_user
  #   end
  # end

  def expect_to_be_signed_in_as_search_user
    expect(page).to have_css("h1", text: "Cosmetic products search")
    expect(page).to have_button "Sign out"
  end

  def expect_to_be_on_the_search_homepage
    expect(page).to have_css("h1", text: "Cosmetic products search")
    expect(page).to have_text("If you’re using this service for the first time")
  end

  def fill_in_account_details_with(password:, full_name: nil, mobile_number: nil, app_code: nil)
    fill_in("Full name", with: full_name) if full_name
    fill_in "Password", with: password
    if mobile_number
      check "Text message"
      fill_in "Mobile number", with: mobile_number
    end
    if app_code
      check "Authenticator app for smartphone or tablet"
      fill_in "Enter the access code", with: app_code
    end
  end

  def otp_code
    invited_user.reload.direct_otp
  end
end
