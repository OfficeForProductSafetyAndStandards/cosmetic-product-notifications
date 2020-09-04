require "rails_helper"

RSpec.feature "Signing up as a submit user", :with_2fa, :with_stubbed_notify, :with_stubbed_mailer, type: :feature do
  before do
    configure_requests_for_submit_domain
  end

  scenario "user signs up and verifies its email" do
    visit "/registration/new_account/new"
    # First attempt with validation errors
    fill_in "Full Name", with: ""
    fill_in "Email address", with: "signing_up.example.com"
    click_button "Continue"


    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link("Enter your full name", href: "#full_name")
    expect(page).to have_css("span#full_name-error", text: "Enter your full name")

    expect(page).to have_link("Enter your email address", href: "#email")
    expect(page).to have_css("span#email-error", text: "Enter your email address")

    fill_in "Full Name", with: "Joe Doe"
    fill_in "Email address", with: "signing_up@example.com"
    click_button "Continue"

    # Submit after fixing te validation issue

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
    # responsible person declaration
  end

  scenario "user signs up and verifies email while signed up as another user" do
    visit "/sign-up"

    fill_in "Name", with: "Test user"
    fill_in "Mobile Number", with: "07000000000"
    fill_in "Email address", with: "signing_up@example.com"
    fill_in "Password", with: "userpassword", match: :prefer_exact
    fill_in "Password confirmation", with: "userpassword", match: :prefer_exact
    click_button "Sign up"

    expect(page).not_to have_css("h2#error-summary-title", text: "There is a problem")
    expect_to_be_on_check_your_email_page

    email = delivered_emails.last
    expect(email.recipient).to eq "signing_up@example.com"
    expect(email.personalization[:name]).to eq("Test user")

    verify_url = email.personalization[:verify_email_url]
    expect(verify_url).to include("/confirmation?confirmation_token=")

    # Visit the confirmation link while signed in as a different user
    second_user = create(:submit_user, :with_responsible_person)
    sign_in(second_user)
    visit verify_url

    # Gets a page asking to choose between continuing as current user or continue  with the confirmation for the
    # new user
    expect(page).to have_css("h1", text: "You are already signed in")
    click_button "Confirm email for Test user"

    # Gets redirected to the sign-in page after verification
    expect(page).to have_current_path("/sign-in")
  end

  def expect_to_be_on_check_your_email_page
    expect(page).to have_css("h1", text: "Check your email")
    expect(page).to have_css(".govuk-body", text: "A message with a confirmation link has been sent to your email address.")
  end

  def user
    raise if SubmitUser.count != 1

    SubmitUser.first
  end
end
