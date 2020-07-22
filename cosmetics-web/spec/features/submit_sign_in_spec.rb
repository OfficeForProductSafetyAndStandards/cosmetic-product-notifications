require "rails_helper"

RSpec.feature "Signing in as a submit user", type: :feature do
  before do
    configure_requests_for_submit_domain
  end

  #You have to confirm your email address before continuing.
  let!(:user) { create(:submit_user, has_accepted_declaration: false) }


  scenario "user signs in for first time" do
    visit "/sign-in"
    fill_in "email", with: user.email
    fill_in "password", with: user.password
    puts page.current_url
    click_on "Continue"
    puts page.current_url
    expect(page).to have_current_path("/declaration?redirect_path=%2Fdashboard")
    expect(page).to have_css("h1", text: "Responsible Person Declaration")
    click_on "I confirm"

    expect(page).to have_css("h1", text: "Are you or your organisation a UK Responsible Person?")
  end

  # scenario "user tries to sign in with email address that does not belong to any user" do
  #   visit "/sign-in"

  #   fill_in "Email address", with: "notarealuser@example.com"
  #   fill_in "Password", with: "notarealpassword"
  #   click_on "Continue"

  #   expect_incorrect_email_or_password
  # end

  # scenario "user introduces wrong password" do
  #   visit "/sign-in"

  #   fill_in "Email address", with: user.email
  #   fill_in "Password", with: "passworD"
  #   click_on "Continue"

  #   expect_incorrect_email_or_password
  # end

  # scenario "user introduces email address with incorrect format" do
  #   visit "/sign-in"

  #   fill_in "Email address", with: "test.email"
  #   fill_in "Password", with: "password "
  #   click_on "Continue"

  #   expect(page).to have_css(".govuk-error-summary__list", text: "Enter your email address in the correct format, like name@example.com")
  #   expect(page).to have_css(".govuk-error-message", text: "Enter your email address in the correct format, like name@example.com")
  # end

  # scenario "user leaves email and password fields empty" do
  #   visit "/sign-in"

  #   fill_in "Email address", with: " "
  #   fill_in "Password", with: " "
  #   click_on "Continue"

  #   expect(page).to have_css(".govuk-error-message", text: "Enter your email address")
  #   expect(page).to have_css(".govuk-error-message", text: "Enter your password")
  # end

  # scenario "user leaves password field empty" do
  #   visit "/sign-in"

  #   fill_in "Email address", with: user.email
  #   fill_in "Password", with: " "
  #   click_on "Continue"

  #   expect(page).to have_css(".govuk-error-message", text: "Enter your password")
  #   expect(page).to have_css(".govuk-error-summary__list", text: "Enter your password")
  # end
end
