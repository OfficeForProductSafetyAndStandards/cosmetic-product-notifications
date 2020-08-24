require "rails_helper"

RSpec.feature "Signing up as a submit user", :with_stubbed_mailer, type: :feature do
  before do
    configure_requests_for_submit_domain
  end

  scenario "user signs up and verifies its email" do
    visit "/sign-up"
    # First attempt with validation errors
    fill_in "Name", with: "Test user"
    fill_in "Mobile Number", with: "07000000" # Mobile number too short
    fill_in "Email address", with: "signing_up@example.com"
    fill_in "Password", with: "userpassword", match: :prefer_exact
    fill_in "Password confirmation", with: "userpassword", match: :prefer_exact
    click_button "Sign up"

    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link("Enter your mobile number in the correct format", href: "#mobile_number")
    expect(page).to have_css("span#mobile_number-error", text: "Enter your mobile number in the correct format")

    # Submit after fixing te validation issue
    fill_in "Mobile Number", with: "07000000000"
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

    # Email verification redirects to the sign in page
    visit verify_url
    expect(page).to have_current_path("/sign-in")

    # Attempt of email verification for second time takes the user to the sign in page
    visit verify_url
    expect(page).to have_current_path("/sign-in")
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
end
