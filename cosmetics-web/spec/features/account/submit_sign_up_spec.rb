require "rails_helper"

RSpec.feature "Signing up as a submit user", :with_2fa, :with_stubbed_notify, :with_stubbed_mailer, type: :feature do
  before do
    configure_requests_for_submit_domain
  end

  scenario "user signs up and verifies its email" do
    visit "/"
    click_on "Create an account"
    expect(page).to have_current_path("/create-an-account")
    # First attempt with validation errors
    fill_in "Full Name", with: ""
    fill_in "Email address", with: "signing_up.example.com"
    click_button "Continue"

    expect(page).to have_current_path("/create-an-account")
    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link("Enter your full name", href: "#full_name")
    expect(page).to have_css("span#full_name-error", text: "Enter your full name")

    expect(page).to have_link("Enter your email address", href: "#email")
    expect(page).to have_css("span#email-error", text: "Enter your email address")

    fill_in "Full Name", with: "Joe Doe"
    fill_in "Email address", with: "signing_up@example.com"
    click_button "Continue"

    expect_to_be_on_check_your_email_page

    email = delivered_emails.last
    expect(email.recipient).to eq "signing_up@example.com"
    expect(email.personalization[:name]).to eq("Joe Doe")

    verify_url = email.personalization[:verify_email_url]
    visit verify_url

    fill_in "Mobile Number", with: "07000000000"
    fill_in "Password", with: "userpassword", match: :prefer_exact
    click_button "Continue"

    expect_user_to_have_received_sms_code(otp_code)
    expect_to_be_on_secondary_authentication_page
    complete_secondary_authentication_with(otp_code)

    expect_to_be_on_declaration_page
  end

  context "when account already exists" do
    let(:user) { create(:submit_user) }

    scenario "sending existing account information to user" do
      visit "/"
      click_on "Create an account"
      expect(page).to have_current_path("/create-an-account")

      fill_in "Full Name", with: "Joe Doe"
      fill_in "Email address", with: user.email
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

        fill_in "Full Name", with: "Joe Doe"
        fill_in "Email address", with: user.email
        click_button "Continue"

        expect_to_be_on_check_your_email_page

        expect(delivered_emails.count).to eq(2)
        email = delivered_emails.last
        expect(email.recipient).to eq user.email
        expect(email.personalization[:name]).to eq user.name

        verify_url = email.personalization[:verify_email_url]
        visit verify_url

        fill_in "Mobile Number", with: "07000000000"
        fill_in "Password", with: "userpassword", match: :prefer_exact
        click_button "Continue"

        expect_user_to_have_received_sms_code(otp_code)
        expect_to_be_on_secondary_authentication_page
        complete_secondary_authentication_with(otp_code)

        expect_to_be_on_declaration_page
      end
    end
  end

  scenario "user signs up and creates new account while signed in as someone else" do
    visit "/"
    click_on "Create an account"
    expect(page).to have_current_path("/create-an-account")

    fill_in "Full Name", with: "Joe Doe"
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

    fill_in "Mobile Number", with: "07000000000"
    fill_in "Password", with: "userpassword", match: :prefer_exact
    click_button "Continue"

    expect_to_be_on_secondary_authentication_page
    complete_secondary_authentication_with(otp_code("signing_up@example.com"))

    expect_to_be_on_declaration_page
  end

  scenario "user signs up and skips creating an account while signed in as someone else" do
    visit "/"
    click_on "Create an account"
    expect(page).to have_current_path("/create-an-account")

    fill_in "Full Name", with: "Joe Doe"
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

    expect(page).to have_css("h1", text: "You are already signed in")
    click_link "Continue as #{second_user.name}"
    expect(page).to have_css("h1", text: "Submit cosmetic product notifications")
    click_link "Your cosmetic products"
    expect(page).to have_css("h1", text: "Your cosmetic products")
  end

  def expect_to_be_on_check_your_email_page
    expect(page).to have_css("h1", text: "Check your email")
    expect(page).to have_css(".govuk-body", text: "A message with a confirmation link has been sent to your email address.")
  end

  def user(email = nil)
    SubmitUser.find_by(email: email) || SubmitUser.first
  end
end
