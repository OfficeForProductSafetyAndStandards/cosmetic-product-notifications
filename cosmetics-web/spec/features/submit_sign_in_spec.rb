require "rails_helper"

RSpec.feature "Signing in as a submit user", type: :feature do
  before do
    configure_requests_for_submit_domain
  end

  let!(:user) { create(:submit_user, has_accepted_declaration: false) }

  def expect_incorrect_email_or_password
    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link("Enter correct email address and password", href: "#email")
    expect(page).to have_css("span#email-error", text: "Error: Enter correct email address and password")
    expect(page).to have_css("span#password-error", text: "")

    expect(page).not_to have_link("Cases")
  end

  scenario "user signs in for first time" do
    visit "/sign-in"
    fill_in "Email address", with: user.email
    fill_in "Password", with: user.password
    puts page.current_url
    click_button "Continue"
    puts page.current_url
    expect(page).to have_current_path("/declaration?redirect_path=%2Fdashboard")
    expect(page).to have_css("h1", text: "Responsible Person Declaration")
    click_button "I confirm"

    expect(page).to have_css("h1", text: "Are you or your organisation a UK Responsible Person?")
  end

  scenario "user tries to sign in with email address that does not belong to any user" do
    visit "/sign-in"

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

    expect(page).to have_css(".govuk-error-summary__list", text: "Enter your email address in the correct format, like name@example.com")
    expect(page).to have_css(".govuk-error-message", text: "Enter your email address in the correct format, like name@example.com")
  end

  scenario "user leaves email and password fields empty" do
    visit "/sign-in"

    fill_in "Email address", with: " "
    fill_in "Password", with: " "
    click_button "Continue"

    expect(page).to have_css(".govuk-error-message", text: "Enter your email address")
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
