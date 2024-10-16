require "rails_helper"

RSpec.feature "Signing up as a submit user", :with_2fa, :with_2fa_app, :with_stubbed_mailer, :with_stubbed_notify, type: :feature do
  before do
    configure_requests_for_submit_domain
  end

  scenario "user signs up and verifies its email", skip: "TODO: Needs to be refactored." do
    visit "/"
    click_on "Create an account"
    expect(page).to have_current_path("/create-an-account")

    fill_in "Full name", with: ""
    fill_in "Email address", with: "signing_up.example.com"
    click_button "Continue"

    expect(page).to have_current_path("/create-an-account")
    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link("Enter your full name", href: "#full_name")
    expect(page).to have_css("p#full_name-error", text: "Enter your full name")

    expect(page).to have_link("Enter an email address", href: "#email")
    expect(page).to have_css("p#email-error", text: "Enter an email address")

    fill_in "Full name", with: "Joe Doe"
    fill_in "Email address", with: "signing_up@example.com"
    click_button "Continue"

    expect_to_be_on_check_your_email_page("signing_up@example.com")

    email = delivered_emails.last
    expect(email.recipient).to eq "signing_up@example.com"
    expect(email.personalization[:name]).to eq("Joe Doe")

    verify_url = email.personalization[:verify_email_url]
    visit verify_url

    expect(page).not_to have_link("Your account")

    click_link "Submit cosmetic product notifications"
    expect(page).to have_current_path("/account-security")

    expect(page).to have_link("How to notify nanomaterials", href: "/guidance/how-to-notify-nanomaterials")
    expect(page).to have_link("How to prepare images for notification", href: "/guidance/how-to-prepare-images-for-notification")
    expect(page).to have_link("Privacy policy", href: "/help/privacy-notice")
    expect(page).to have_link("Terms and conditions", href: "/help/terms-and-conditions")
    expect(page).to have_link("Accessibility statement", href: "/help/accessibility-statement")

    click_button "Continue"
    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_css("p#password-error", text: "Error: Enter a password")

    fill_in "Create your password", with: "@dki£", match: :prefer_exact
    click_button "Continue"
    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_css("p#password-error", text: "Error: Password must be at least 8 characters")

    fill_in "Create your password", with: "password", match: :prefer_exact
    click_button "Continue"
    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_css("p#password-error", text: "Error: Choose a less frequently used password")

    fill_in "Create your password", with: "pass", match: :prefer_exact
    click_button "Continue"
    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_css("p#password-error", text: "Error: Password must be at least 8 characters")

    fill_in "Create your password", with: "userpassword12345", match: :prefer_exact
    click_button "Continue"

    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link("Select how to get an access code", href: "#app_authentication")

    fill_in "Create your password", with: "userpassword", match: :prefer_exact
    check "Authenticator app for smartphone or tablet"
    fill_in "Enter the access code", with: "000000"
    check "Text message"
    fill_in "Mobile number", with: "07000 invalid 000000"

    original_secret_key = page.find("p", text: "Secret key:").text

    click_button "Continue"

    expect(page).to have_current_path("/account-security")
    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link("Enter a correct code", href: "#app_authentication_code")
    expect(page).to have_link("Enter a mobile number, like 07700 900 982 or +44 7700 900 982", href: "#mobile_number")
    expect(page).to have_css("p#app_authentication_code-error", text: "Enter a correct code")
    expect(page).to have_css("p#mobile_number-error", text: "Enter a mobile number, like 07700 900 982 or +44 7700 900 982")

    fill_in "Create your password", with: "userpassword", match: :prefer_exact
    check "Authenticator app for smartphone or tablet"
    fill_in "Enter the access code", with: correct_app_code
    check "Text message"
    fill_in "Mobile number", with: "07000000000"

    reloaded_secret_key = page.find("p", text: "Secret key:").text
    expect(reloaded_secret_key).to eq original_secret_key

    click_button "Continue"

    expect_to_be_on_secondary_authentication_sms_page
    expect(page).not_to have_link("Back", href: "/two-factor/method")
    expect_user_to_have_received_sms_code(otp_code)
    complete_secondary_authentication_sms_with(otp_code)

    expect_to_be_on_secondary_authentication_recovery_codes_setup_page
    SubmitUser.last.secondary_authentication_recovery_codes.each do |code|
      normalized_code = code.scan(/.{1,4}/).join(" ")
      expect(page).to have_css("div.opss-recovery-codes", text: normalized_code)
    end
    click_link "Continue"

    expect_to_be_on_account_overview_page
  end

  scenario "user signs up with authentication app 2FA but without text message", skip: "TODO: Needs to be refactored." do
    visit "/"
    click_on "Create an account"
    expect(page).to have_current_path("/create-an-account")

    fill_in "Full name", with: "Joe Doe"
    fill_in "Email address", with: "signing_up@example.com"
    click_button "Continue"

    expect_to_be_on_check_your_email_page("signing_up@example.com")

    email = delivered_emails.last
    expect(email.recipient).to eq "signing_up@example.com"
    expect(email.personalization[:name]).to eq("Joe Doe")

    verify_url = email.personalization[:verify_email_url]
    visit verify_url

    expect(page).to have_current_path("/account-security")
    fill_in "Create your password", with: "userpassword", match: :prefer_exact
    check "Authenticator app for smartphone or tablet"
    fill_in "Enter the access code", with: correct_app_code
    click_button "Continue"

    expect_to_be_on_secondary_authentication_recovery_codes_setup_page
    SubmitUser.last.secondary_authentication_recovery_codes.each do |code|
      normalized_code = code.scan(/.{1,4}/).join(" ")
      expect(page).to have_css("div.opss-recovery-codes", text: normalized_code)
    end
    click_link "Continue"

    expect_to_be_on_account_overview_page
  end

  scenario "user signs up originally selecting both text and app methods but then moving back to only use the app", skip: "TODO: Needs to be refactored." do
    visit "/"
    click_on "Create an account"
    expect(page).to have_current_path("/create-an-account")

    fill_in "Full name", with: "Joe Doe"
    fill_in "Email address", with: "signing_up@example.com"
    click_button "Continue"

    expect_to_be_on_check_your_email_page("signing_up@example.com")

    email = delivered_emails.last
    expect(email.recipient).to eq "signing_up@example.com"
    expect(email.personalization[:name]).to eq("Joe Doe")

    verify_url = email.personalization[:verify_email_url]
    visit verify_url

    expect(page).to have_current_path("/account-security")
    fill_in "Create your password", with: "userpassword", match: :prefer_exact
    check "Authenticator app for smartphone or tablet"
    fill_in "Enter the access code", with: correct_app_code
    check "Text message"
    fill_in "Mobile number", with: "07000000000"
    click_button "Continue"

    expect_to_be_on_secondary_authentication_sms_page
    expect_user_to_have_received_sms_code(otp_code)
    expect(page).to have_button("Back")
    click_button("Back")

    expect(page).to have_current_path("/account-security")
    expect(page).to have_checked_field("Authenticator app for smartphone or tablet")
    expect(page).to have_checked_field("Text message")
    expect(page).to have_field("Mobile number", with: "07000000000")

    uncheck "Text message"
    fill_in "Create your password", with: "userpassword", match: :prefer_exact
    fill_in "Enter the access code", with: correct_app_code
    click_button "Continue"

    expect_to_be_on_secondary_authentication_recovery_codes_setup_page
    SubmitUser.last.secondary_authentication_recovery_codes.each do |code|
      normalized_code = code.scan(/.{1,4}/).join(" ")
      expect(page).to have_css("div.opss-recovery-codes", text: normalized_code)
    end
    click_link "Continue"

    expect_to_be_on_account_overview_page
  end

  scenario "user signs up and verifies its email with 2FA disabled for the environment", skip: "TODO: Needs to be refactored.", with_2fa: false do
    visit "/"
    click_on "Create an account"
    expect(page).to have_current_path("/create-an-account")

    fill_in "Full name", with: ""
    fill_in "Email address", with: "signing_up.example.com"
    click_button "Continue"

    expect(page).to have_current_path("/create-an-account")
    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link("Enter your full name", href: "#full_name")
    expect(page).to have_css("p#full_name-error", text: "Enter your full name")

    expect(page).to have_link("Enter an email address", href: "#email")
    expect(page).to have_css("p#email-error", text: "Enter an email address")

    fill_in "Full name", with: "Joe Doe"
    fill_in "Email address", with: "signing_up@example.com"
    click_button "Continue"

    expect_to_be_on_check_your_email_page("signing_up@example.com")

    email = delivered_emails.last
    expect(email.recipient).to eq "signing_up@example.com"
    expect(email.personalization[:name]).to eq("Joe Doe")

    verify_url = email.personalization[:verify_email_url]
    visit verify_url

    fill_in "Create your password", with: "userpassword", match: :prefer_exact
    check "Text message"
    fill_in "Mobile number", with: "07000000000"
    click_button "Continue"

    expect_to_be_on_secondary_authentication_recovery_codes_setup_page
    SubmitUser.last.secondary_authentication_recovery_codes.each do |code|
      normalized_code = code.scan(/.{1,4}/).join(" ")
      expect(page).to have_css("div.opss-recovery-codes", text: normalized_code)
    end
    click_link "Continue"

    expect_to_be_on_account_overview_page
  end

  scenario "user signs up and verifies its email with, confirmation expired during the process", skip: "TODO: Needs to be refactored." do
    visit "/"
    click_on "Create an account"
    expect(page).to have_current_path("/create-an-account")

    fill_in "Full name", with: "Joe Doe"
    fill_in "Email address", with: "signing_up@example.com"
    click_button "Continue"

    expect_to_be_on_check_your_email_page("signing_up@example.com")

    # Simulate time travel to expire the token
    travel_to 3.days.from_now do
      email = delivered_emails.last

      expect(email.recipient).to eq "signing_up@example.com"
      expect(email.personalization[:name]).to eq("Joe Doe")

      verify_url = email.personalization[:verify_email_url]
      visit verify_url

      expect(page).to have_current_path("/#{verify_url}")
      expect(page).to have_css("h1", text: "Confirmation token is expired or invalid")

      visit verify_url[0..-2]
      expect(page).to have_css("h1", text: "Confirmation token is expired or invalid")

      visit verify_url

      fill_in "Create your password", with: "userpassword", match: :prefer_exact
      check "Text message"
      fill_in "Mobile number", with: "07000000000"
      click_button "Continue"

      expect_to_be_on_secondary_authentication_sms_page
      complete_secondary_authentication_sms_with(otp_code)

      expect_to_be_on_secondary_authentication_recovery_codes_setup_page
      SubmitUser.last.secondary_authentication_recovery_codes.each do |code|
        normalized_code = code.scan(/.{1,4}/).join(" ")
        expect(page).to have_css("div.opss-recovery-codes", text: normalized_code)
      end
      click_link "Continue"

      expect_to_be_on_account_overview_page
    end
  end

  context "when account already exists", skip: "TODO: Needs to be refactored." do
    let(:user) { create(:submit_user) }

    scenario "sending existing account information to user" do
      visit "/"
      click_on "Create an account"
      expect(page).to have_current_path("/create-an-account")

      fill_in "Full name", with: "Joe Doe"
      fill_in "Email address", with: user.email.upcase
      click_button "Continue"

      expect_to_be_on_check_your_email_page(user.email.upcase)

      email = delivered_emails.last
      expect(email.recipient).to eq user.email
      expect(email.personalization[:name]).to eq user.name

      sign_in_url = email.personalization[:sign_in_url]
      forgotten_password_url = email.personalization[:forgotten_password_url]

      visit sign_in_url
      expect(page).to have_current_path("/sign-in")

      visit forgotten_password_url
      expect(page).to have_current_path("/password/new")
    end

    context "when user is not confirmed" do
      let!(:user) { create(:submit_user, :unconfirmed, email: "signing_up@example.com") }

      scenario "sending account reconfirmation to unconfirmed email" do
        expect(delivered_emails.count).to eq(1)
        visit "/"
        click_on "Create an account"
        expect(page).to have_current_path("/create-an-account")

        fill_in "Full name", with: "Joe Doe"
        fill_in "Email address", with: user.email
        click_button "Continue"

        expect_to_be_on_check_your_email_page(user.email)

        expect(delivered_emails.count).to eq(2)
        email = delivered_emails.last
        expect(email.recipient).to eq user.email
        expect(email.personalization[:name]).to eq user.name

        verify_url = email.personalization[:verify_email_url]
        visit verify_url

        fill_in "Create your password", with: "userpassword", match: :prefer_exact
        check "Text message"
        fill_in "Mobile number", with: "07000000000"
        click_button "Continue"

        expect_user_to_have_received_sms_code(otp_code)
        expect_to_be_on_secondary_authentication_sms_page
        complete_secondary_authentication_sms_with(otp_code)

        expect_to_be_on_secondary_authentication_recovery_codes_setup_page

        new_user = SubmitUser.find_by(email: "signing_up@example.com")
        expect(new_user).not_to be_nil

        new_user.secondary_authentication_recovery_codes.each do |code|
          normalized_code = code.scan(/.{1,4}/).join(" ")
          expect(page).to have_css("div.opss-recovery-codes", text: normalized_code)
        end
        click_link "Continue"

        expect_to_be_on_account_overview_page
      end
    end

    context "when user was invited to a responsible persons and followed the link but haven't completed their registration" do
      let(:responsible_person) { create(:responsible_person, :with_a_contact_person, name: "Responsible Person") }
      let(:invitation) do
        create(:pending_responsible_person_user, email_address: "inviteduser@example.com", responsible_person:)
      end

      scenario "resends the responsible person invitation email" do
        invitation_path = "/responsible_persons/#{responsible_person.id}/team_members/join?invitation_token=#{invitation.invitation_token}"
        visit invitation_path
        expect(page).to have_current_path("/account-security")
        expect(page).to have_css("h1", text: "Setup your account")
        expect(page).to have_field("Full name")

        click_button "Sign out"

        click_on "Create an account"
        expect(page).to have_current_path("/create-an-account")

        fill_in "Full name", with: "Joe Doe"
        fill_in "Email address", with: "inviteduser@example.com"
        click_button "Continue"

        expect(delivered_emails.size).to eq 1
        email = delivered_emails.first

        expect(email.recipient).to eq "inviteduser@example.com"
        expect(email.reference).to eq "Invite user to join Responsible Person"
        expect(email.template).to eq SubmitNotifyMailer::TEMPLATES[:responsible_person_invitation_for_existing_user]
        expect(email.personalization).to eq(
          invitation_url: "http://#{ENV.fetch('SUBMIT_HOST')}#{invitation_path}",
          responsible_person: responsible_person.name,
          invite_sender: invitation.inviting_user.name,
        )
        expect_to_be_on_check_your_email_page("inviteduser@example.com")

        visit invitation_path
        expect(page).to have_current_path("/account-security")
        expect(page).to have_css("h1", text: "Setup your account")
        expect(page).to have_field("Full name")
      end
    end
  end

  scenario "user signs up and creates new account while signed in as someone else", skip: "TODO: Needs to be refactored." do
    visit "/"
    click_on "Create an account"
    expect(page).to have_current_path("/create-an-account")

    fill_in "Full name", with: "Joe Doe"
    fill_in "Email address", with: "signing_up@example.com"
    click_button "Continue"

    expect_to_be_on_check_your_email_page("signing_up@example.com")

    email = delivered_emails.last
    expect(email.recipient).to eq "signing_up@example.com"
    expect(email.personalization[:name]).to eq("Joe Doe")

    verify_url = email.personalization[:verify_email_url]

    second_user = create(:submit_user, :with_responsible_person)
    sign_in(second_user)

    visit verify_url

    click_on "Create new account"

    fill_in "Create your password", with: "userpassword", match: :prefer_exact
    check "Text message"
    fill_in "Mobile number", with: "07000000000"
    click_button "Continue"

    expect_to_be_on_secondary_authentication_sms_page
    complete_secondary_authentication_sms_with(otp_code("signing_up@example.com"))

    expect_to_be_on_secondary_authentication_recovery_codes_setup_page
    new_user = SubmitUser.find_by(email: "signing_up@example.com")
    expect(new_user).not_to be_nil

    new_user.secondary_authentication_recovery_codes.each do |code|
      normalized_code = code.scan(/.{1,4}/).join(" ")
      expect(page).to have_css("div.opss-recovery-codes", text: normalized_code)
    end
    click_link "Continue"

    expect_to_be_on_account_overview_page
  end

  scenario "user signs up and skips creating an account while signed in as someone else", skip: "TODO: Needs to be refactored." do
    visit "/"
    click_on "Create an account"
    expect(page).to have_current_path("/create-an-account")

    fill_in "Full name", with: "Joe Doe"
    fill_in "Email address", with: "signing_up@example.com"
    click_button "Continue"

    expect_to_be_on_check_your_email_page("signing_up@example.com")

    email = delivered_emails.last
    expect(email.recipient).to eq "signing_up@example.com"
    expect(email.personalization[:name]).to eq "Joe Doe"

    verify_url = email.personalization[:verify_email_url]

    second_user = create(:submit_user, :with_sms_secondary_authentication, :with_responsible_person)
    sign_in(second_user)

    visit verify_url

    expect(page).to have_css("h1", text: "You are already signed in")
    click_link "Continue as #{second_user.name}"
    expect(page).to have_css("h1", text: "Submit cosmetic product notifications")
    click_link "cosmetic products page"
    expect(page).to have_css("h1", text: "Product notifications")
  end

  scenario "registered user can not access account security" do
    user = create(:submit_user, :with_responsible_person)

    sign_in(user)
    visit "/account-security"

    expect(page).not_to have_css("h1", text: "Setup your account")
    expect(page).to have_css("h1", text: "Submit cosmetic product notifications")
  end

  scenario "spam user attempts to sign up", skip: "TODO: Needs to be refactored." do
    visit "/"
    click_on "Create an account"
    expect(page).to have_current_path("/create-an-account")

    fill_in "Full name", with: "Hello join http://spam.com"
    fill_in "Email address", with: "signing_up@example.com"
    click_button "Continue"

    expect(page).to have_current_path("/create-an-account")
    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link("Enter a valid name", href: "#full_name")
    expect(page).to have_css("p#full_name-error", text: "Enter a valid name")
  end

  def expect_to_be_on_check_your_email_page(email)
    expect(page).to have_css("h1", text: "Check your email")
    expect(page).to have_css(".govuk-body", text: "A message with a confirmation link has been sent to #{email}.")
  end

  def user(email = nil)
    SubmitUser.find_by(email:) || SubmitUser.first
  end
end
