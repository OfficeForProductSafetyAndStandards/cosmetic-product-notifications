require "rails_helper"

RSpec.feature "Signing up as a submit user", :with_2fa, :with_2fa_app, :with_stubbed_notify, :with_stubbed_mailer, type: :feature do
  before do
    configure_requests_for_submit_domain
  end

  scenario "user signs up and verifies its email" do
    visit "/"
    click_on "Create an account"
    expect(page).to have_current_path("/create-an-account")

    # First attempt with validation errors
    fill_in "Full name", with: ""
    fill_in "Email address", with: "signing_up.example.com"
    click_button "Continue"

    expect(page).to have_current_path("/create-an-account")
    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link("Enter your full name", href: "#full_name")
    expect(page).to have_css("span#full_name-error", text: "Enter your full name")

    expect(page).to have_link("Enter your email address", href: "#email")
    expect(page).to have_css("span#email-error", text: "Enter your email address")

    # Second attempt with no validation issues
    fill_in "Full name", with: "Joe Doe"
    fill_in "Email address", with: "signing_up@example.com"
    click_button "Continue"

    expect_to_be_on_check_your_email_page

    email = delivered_emails.last
    expect(email.recipient).to eq "signing_up@example.com"
    expect(email.personalization[:name]).to eq("Joe Doe")

    verify_url = email.personalization[:verify_email_url]
    visit verify_url

    # Some links should not be shown to users during the sign up flow
    expect(page).not_to have_link("Your account")

    click_link "Submit cosmetic product notifications"
    expect(page).to have_current_path("/account-security")

    expect(page).to have_link("How to notify nanomaterials", href: "/guidance/how-to-notify-nanomaterials")
    expect(page).to have_link("How to prepare images for notification", href: "/guidance/how-to-prepare-images-for-notification")
    expect(page).to have_link("Privacy policy", href: "/help/privacy-notice")
    expect(page).to have_link("Terms and conditions", href: "/help/terms-and-conditions")
    expect(page).to have_link("Accessibility Statement", href: "/help/accessibility-statement")

    # Attempts to submit security page without selecting secondary authentication method
    fill_in "Create your password", with: "userpassword", match: :prefer_exact
    click_button "Continue"

    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link("Select how to get an access code", href: "#app_authentication")

    # Attempts to submit security page with invalid phone and wrong app authentication code
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
    expect(page).to have_css("span#app_authentication_code-error", text: "Enter a correct code")
    expect(page).to have_css("span#mobile_number-error", text: "Enter a mobile number, like 07700 900 982 or +44 7700 900 982")

    # New attempt setting both secondary authentication methods with no issues
    fill_in "Create your password", with: "userpassword", match: :prefer_exact
    check "Authenticator app for smartphone or tablet"
    fill_in "Enter the access code", with: correct_app_code
    check "Text message"
    fill_in "Mobile number", with: "07000000000"

    # Ensure that the secret key/QR code don't change between failed attempts
    reloaded_secret_key = page.find("p", text: "Secret key:").text
    expect(reloaded_secret_key).to eq original_secret_key

    click_button "Continue"

    expect_to_be_on_secondary_authentication_sms_page
    expect(page).not_to have_link("Back", href: "/two-factor/method")
    expect_user_to_have_received_sms_code(otp_code)
    complete_secondary_authentication_sms_with(otp_code)

    expect_to_be_on_declaration_page
  end

  scenario "user signs up with authentication app 2FA but without text message" do
    visit "/"
    click_on "Create an account"
    expect(page).to have_current_path("/create-an-account")

    fill_in "Full name", with: "Joe Doe"
    fill_in "Email address", with: "signing_up@example.com"
    click_button "Continue"

    expect_to_be_on_check_your_email_page

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

    expect_to_be_on_declaration_page
  end

  scenario "user signs up originally selecting both text and app methods but then moving back to only use the app" do
    visit "/"
    click_on "Create an account"
    expect(page).to have_current_path("/create-an-account")

    fill_in "Full name", with: "Joe Doe"
    fill_in "Email address", with: "signing_up@example.com"
    click_button "Continue"

    expect_to_be_on_check_your_email_page

    email = delivered_emails.last
    expect(email.recipient).to eq "signing_up@example.com"
    expect(email.personalization[:name]).to eq("Joe Doe")

    verify_url = email.personalization[:verify_email_url]
    visit verify_url

    # User reaches account security page and select both text and app methods
    expect(page).to have_current_path("/account-security")
    fill_in "Create your password", with: "userpassword", match: :prefer_exact
    check "Authenticator app for smartphone or tablet"
    fill_in "Enter the access code", with: correct_app_code
    check "Text message"
    fill_in "Mobile number", with: "07000000000"
    click_button "Continue"

    # User decides to not use text authentication and goes back to change the account security preferences
    expect_to_be_on_secondary_authentication_sms_page
    expect_user_to_have_received_sms_code(otp_code)
    expect(page).to have_link("Back", href: "/account-security")
    click_link("Back")

    expect(page).to have_current_path("/account-security")
    # Account Security form has the previously values pre-filled
    expect(page).to have_checked_field("Authenticator app for smartphone or tablet")
    expect(page).to have_checked_field("Text message")
    expect(page).to have_field("Mobile number", with: "07000000000")

    # Finally user unchecks the text message authentication and re-submits the form
    uncheck "Text message"
    fill_in "Create your password", with: "userpassword", match: :prefer_exact
    fill_in "Enter the access code", with: correct_app_code
    click_button "Continue"

    expect_to_be_on_declaration_page
  end

  scenario "user signs up and verifies its email with 2FA disabled for the environment", with_2fa: false do
    visit "/"
    click_on "Create an account"
    expect(page).to have_current_path("/create-an-account")
    # First attempt with validation errors
    fill_in "Full name", with: ""
    fill_in "Email address", with: "signing_up.example.com"
    click_button "Continue"

    expect(page).to have_current_path("/create-an-account")
    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link("Enter your full name", href: "#full_name")
    expect(page).to have_css("span#full_name-error", text: "Enter your full name")

    expect(page).to have_link("Enter your email address", href: "#email")
    expect(page).to have_css("span#email-error", text: "Enter your email address")

    fill_in "Full name", with: "Joe Doe"
    fill_in "Email address", with: "signing_up@example.com"
    click_button "Continue"

    expect_to_be_on_check_your_email_page

    email = delivered_emails.last
    expect(email.recipient).to eq "signing_up@example.com"
    expect(email.personalization[:name]).to eq("Joe Doe")

    verify_url = email.personalization[:verify_email_url]
    visit verify_url

    fill_in "Create your password", with: "userpassword", match: :prefer_exact
    check "Text message"
    fill_in "Mobile number", with: "07000000000"
    click_button "Continue"

    expect_to_be_on_declaration_page
  end

  scenario "user signs up and verifies its email with, confirmation expired during the process" do
    visit "/"
    click_on "Create an account"
    expect(page).to have_current_path("/create-an-account")
    # First attempt with validation errors

    fill_in "Full name", with: "Joe Doe"
    fill_in "Email address", with: "signing_up@example.com"
    click_button "Continue"

    expect_to_be_on_check_your_email_page

    travel_to(3.days.from_now)
    email = delivered_emails.last
    expect(email.recipient).to eq "signing_up@example.com"
    expect(email.personalization[:name]).to eq("Joe Doe")

    verify_url = email.personalization[:verify_email_url]
    visit verify_url

    expect(page).to have_css("h1", text: "Confirmation token is expired or invalid")

    email = delivered_emails.last
    expect(email.recipient).to eq "signing_up@example.com"
    expect(email.personalization[:name]).to eq("Joe Doe")

    verify_url = email.personalization[:verify_email_url]

    visit verify_url[0..-2]
    expect(page).to have_css("h1", text: "Confirmation token is expired or invalid")

    visit verify_url

    fill_in "Create your password", with: "userpassword", match: :prefer_exact
    check "Text message"
    fill_in "Mobile number", with: "07000000000"
    click_button "Continue"

    expect_to_be_on_secondary_authentication_sms_page
    complete_secondary_authentication_sms_with(otp_code)

    expect_to_be_on_declaration_page
  end

  context "when account already exists" do
    let(:user) { create(:submit_user) }

    scenario "sending existing account information to user" do
      visit "/"
      click_on "Create an account"
      expect(page).to have_current_path("/create-an-account")

      fill_in "Full name", with: "Joe Doe"
      fill_in "Email address", with: user.email.upcase
      click_button "Continue"

      expect_to_be_on_check_your_email_page

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
      let!(:user) { create(:submit_user, :unconfirmed) }

      scenario "sending account reconfirmation to unconfirmed email" do
        # Guard for confirmation email
        expect(delivered_emails.count).to eq(1)
        visit "/"
        click_on "Create an account"
        expect(page).to have_current_path("/create-an-account")

        fill_in "Full name", with: "Joe Doe"
        fill_in "Email address", with: user.email
        click_button "Continue"

        expect_to_be_on_check_your_email_page

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

        expect_to_be_on_declaration_page
      end
    end

    context "when user was invited to a responsible persons and followed the link but haven't completed their registration" do
      let(:responsible_person) { create(:responsible_person, :with_a_contact_person, name: "Responsible Person") }
      let(:invitation) do
        create(:pending_responsible_person_user, email_address: "inviteduser@example.com", responsible_person: responsible_person)
      end

      scenario "resends the responsible person invitation email" do
        # Invited user visits the link from the RP invitation email
        invitation_path = "/responsible_persons/#{responsible_person.id}/team_members/join?invitation_token=#{invitation.invitation_token}"
        visit invitation_path
        expect(page).to have_current_path("/account-security")
        expect(page).to have_css("h1", text: "Setup your account")
        expect(page).to have_field("Full name")

        # User abandons the registration process
        click_link "Sign out"

        # After a while, user tries to Sign Up from scratch
        click_on "Create an account"
        expect(page).to have_current_path("/create-an-account")

        fill_in "Full name", with: "Joe Doe"
        fill_in "Email address", with: "inviteduser@example.com"
        click_button "Continue"

        # Instead of receiving a confirmation email, user receives the invitation email again
        expect(delivered_emails.size).to eq 1
        email = delivered_emails.first

        expect(email.recipient).to eq "inviteduser@example.com"
        expect(email.reference).to eq "Invite user to join responsible person"
        expect(email.template).to eq SubmitNotifyMailer::TEMPLATES[:responsible_person_invitation_for_existing_user]
        expect(email.personalization).to eq(
          invitation_url: "http://#{ENV.fetch('SUBMIT_HOST')}#{invitation_path}",
          responsible_person: responsible_person.name,
          invite_sender: invitation.inviting_user.name,
        )
        expect_to_be_on_check_your_email_page

        # Invitation link takes the user to the account completion page
        visit invitation_path
        expect(page).to have_current_path("/account-security")
        expect(page).to have_css("h1", text: "Setup your account")
        expect(page).to have_field("Full name")
      end
    end
  end

  scenario "user signs up and creates new account while signed in as someone else" do
    visit "/"
    click_on "Create an account"
    expect(page).to have_current_path("/create-an-account")

    fill_in "Full name", with: "Joe Doe"
    fill_in "Email address", with: "signing_up@example.com"
    click_button "Continue"

    expect_to_be_on_check_your_email_page

    email = delivered_emails.last
    expect(email.recipient).to eq "signing_up@example.com"
    expect(email.personalization[:name]).to eq("Joe Doe")

    verify_url = email.personalization[:verify_email_url]

    second_user = create(:submit_user, :with_responsible_person)
    sign_in(second_user)

    # Visit the confirmation link while signed in as a different user
    visit verify_url

    click_on "Create new account"

    fill_in "Create your password", with: "userpassword", match: :prefer_exact
    check "Text message"
    fill_in "Mobile number", with: "07000000000"
    click_button "Continue"

    expect_to_be_on_secondary_authentication_sms_page
    complete_secondary_authentication_sms_with(otp_code("signing_up@example.com"))

    expect_to_be_on_declaration_page
  end

  scenario "user signs up and skips creating an account while signed in as someone else" do
    visit "/"
    click_on "Create an account"
    expect(page).to have_current_path("/create-an-account")

    fill_in "Full name", with: "Joe Doe"
    fill_in "Email address", with: "signing_up@example.com"
    click_button "Continue"

    expect_to_be_on_check_your_email_page

    email = delivered_emails.last
    expect(email.recipient).to eq "signing_up@example.com"
    expect(email.personalization[:name]).to eq("Joe Doe")

    verify_url = email.personalization[:verify_email_url]

    second_user = create(:submit_user, :with_sms_secondary_authentication, :with_responsible_person)
    sign_in(second_user)

    # Visit the confirmation link while signed in as a different user
    visit verify_url

    expect(page).to have_css("h1", text: "You are already signed in")
    click_link "Continue as #{second_user.name}"
    expect(page).to have_css("h1", text: "Submit cosmetic product notifications")
    click_link "Your cosmetic products"
    expect(page).to have_css("h1", text: "Your cosmetic products")
  end

  scenario "registered user can not access account security" do
    user = create(:submit_user, :with_responsible_person)

    sign_in(user)
    visit "/account-security"

    expect(page).not_to have_css("h1", text: "Setup your account")
    expect(page).to have_css("h1", text: "Submit cosmetic product notifications")
  end

  def expect_to_be_on_check_your_email_page
    expect(page).to have_css("h1", text: "Check your email")
    expect(page).to have_css(".govuk-body", text: "A message with a confirmation link has been sent to your email address.")
  end

  def user(email = nil)
    SubmitUser.find_by(email: email) || SubmitUser.first
  end
end
