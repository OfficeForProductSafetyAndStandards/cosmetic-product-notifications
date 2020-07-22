require "rails_helper"

RSpec.feature "Signing up as a submit user", :with_stubbed_mailer, type: :feature do
  before do
    configure_requests_for_submit_domain
  end

  scenario "user signs up and verifies its email" do
    visit "/sign-up"
    fill_in "Name", with: "Test user"
    fill_in "Mobile Number", with: "07000000000"
    fill_in "Email address", with: "signing_up@example.com"
    fill_in "Password", with: "userpassword", match: :prefer_exact
    fill_in "Password confirmation", with: "userpassword", match: :prefer_exact
    click_button "Sign up"

    expect(page).to have_css("h1", text: "Check your email")
    expect(page).to have_css(".govuk-body", text: "A message with a confirmation link has been sent to your email address.")

    email = delivered_emails.last
    expect(email.recipient).to eq "signing_up@example.com"
    expect(email.personalization[:name]).to eq("Test user")

    verify_url = email.personalization[:verify_email_url]
    expect(verify_url).to include("/confirmation?confirmation_token=")

    # Email verification redirects to the sign in page
    visit verify_url
    expect(page).to have_current_path("/sign-in")

    # Attempt of email verification for second time takes the user to the confirmation page and shows an error
    visit verify_url
    expect(page).to have_current_path(verify_url)
    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_css(".govuk-error-summary__list", text: "already confirmed, please try signing in")
    expect(page).to have_button("Resend confirmation instructions")
  end
end
