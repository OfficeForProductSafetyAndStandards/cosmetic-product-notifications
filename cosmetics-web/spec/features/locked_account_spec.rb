require "rails_helper"

RSpec.feature "Unlockin account", :with_stubbed_mailer, :feature do
  before do
    configure_requests_for_submit_domain
    Capybara.app_host = 'http://submit'
  end

  let(:user) { create(:submit_user) }

  def fill_in_credentials(password_override: nil)
    fill_in "Email address", with: user.email
    if password_override
      fill_in "Password", with: password_override
    else
      fill_in "Password", with: user.password
    end
    click_on "Continue"
  end


  context "when using wrong credentials over and over again" do
    let(:unlock_email) { delivered_emails.last }
    let(:unlock_path) { unlock_email.personalization_path(:unlock_user_url_token) }

    scenario "user gets locked and uses the unlock link received by email" do
      Devise.maximum_attempts.times do
        visit "/sign-in"
        fill_in_credentials(password_override: "XXX")
      end

      expect(page).to have_css("p", text: "We’ve locked this account to protect its security.")

      visit unlock_path

      # TODO
      # expect(page).to have_css("h1", text: "Check your phone")

      # fill_in "Enter security code", with: otp_code
      # click_on "Continue"

      fill_in_credentials


      expect(page).to have_css("h1", text: "Are you or your organisation")
      expect(page).to have_link("Sign out")
    end

    # TODO
    # scenario "user tries to use unlock link when logged in as different user" do
    #   user2 = create(:user, :activated, has_viewed_introduction: true)
    #   user2.lock_access!

    #   visit "/sign-in"
    #   fill_in_credentials
    #   fill_in "Enter security code", with: otp_code
    #   click_on "Continue"

    #   expect(page).to have_css("h2", text: "Your cases")

    #   visit unlock_path
    #   expect(page).to have_css("h1", text: "Check your phone")
    # end

    scenario "user follows an invalid unlock link" do
      visit "/unlock?unlock_token=wrong-token"
      expect(page).to have_css("h1", text: "Invalid link")
      expect(page.status_code).to eq(404)
    end

    scenario "locked user receives email with reset password link" do
      Devise.maximum_attempts.times do
        visit "/sign-in"
        fill_in_credentials(password_override: "XXX")
      end

      expect(page).to have_css("p", text: "We’ve locked this account to protect its security.")

      unlock_email = delivered_emails.last
      visit unlock_email.personalization_path(:edit_user_password_url_token)

      # expect(page).to have_css("h1", text: "Check your phone")

      # fill_in "Enter security code", with: otp_code
      # click_on "Continue"

      expect(page).to have_css("h1", text: "Create a new password")
    end
  end
end
