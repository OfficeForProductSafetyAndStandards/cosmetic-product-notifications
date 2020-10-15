require "rails_helper"

RSpec.feature "Resetting your password", :with_test_queue_adapter, :with_stubbed_mailer, :with_2fa, type: :feature do
  shared_examples "password reset" do
    scenario "entering an email which does not match an account does not send a notification but shows the confirmation page" do
      user.update!(reset_password_token: reset_token)

      visit "/sign-in"

      click_link "Forgot your password?"

      perform_enqueued_jobs do
        expect(page).to have_css("h1", text: "Reset your password")
        fill_in "Email address", with: Faker::Internet.safe_email
        click_on "Send email"

        expect(delivered_emails).to be_empty
        expect_to_be_on_check_your_email_page
      end
    end

    scenario "entering an invalid email shows an error" do
      visit "/sign-in"

      click_link "Forgot your password?"

      expect(page).to have_css("h1", text: "Reset your password")

      fill_in "Email address", with: "not_an_email"
      click_on "Send email"

      expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
      expect(page).to have_link("Enter your email address in the correct format, like name@example.com", href: "#email")
    end

    context "with a valid token" do
      scenario "entering a valid password resets your password" do
        request_password_reset

        visit edit_user_password_url_with_token

        expect_to_be_on_secondary_authentication_page

        # User can request the 2FA code again
        click_link "Not received a text message?"

        expect_to_be_on_resend_secondary_authentication_page
        click_button "Resend security code"

        expect_to_be_on_secondary_authentication_page
        complete_secondary_authentication_with(otp_code)

        # User updates its password
        expect_to_be_on_edit_user_password_page

        expect(page).to have_field("username", type: "email", with: user.email, disabled: true)

        fill_in "Password", with: "a_new_password"
        click_on "Continue"

        expect_to_be_on_password_changed_page

        click_link "Continue"

        # User is signed in in the landing page for Submit/Search
        expect(page).to have_css("h1", text: expected_text)
        click_on "Sign out"

        # Attempting to use the link after already having setup the new password shows an "invalid link" error page
        visit edit_user_password_url_with_token
        expect(page).to have_css("h1", text: "Invalid link")
        click_on "sign in page"

        # User signs in using the new password
        fill_in "Email address", with: user.email
        fill_in "Password", with: "a_new_password"
        click_on "Continue"

        expect(page).to have_css("h1", text: expected_text)
      end

      context "when the password does not fit the criteria" do
        scenario "when the password is too short it shows an error" do
          request_password_reset

          visit edit_user_password_url_with_token

          expect_to_be_on_secondary_authentication_page
          complete_secondary_authentication_with(otp_code)

          expect_to_be_on_edit_user_password_page

          fill_in "Password", with: "as"
          click_on "Continue"

          expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
          expect(page).to have_link("Password is too short", href: "#password")

          expect(page).to have_field("username", type: "email", with: user.email, disabled: true)
        end

        scenario "when the password is empty it shows an error" do
          request_password_reset

          visit edit_user_password_url_with_token

          expect_to_be_on_secondary_authentication_page
          complete_secondary_authentication_with(otp_code)

          expect_to_be_on_edit_user_password_page

          fill_in "Password", with: ""
          click_on "Continue"

          expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
          expect(page).to have_link("Enter a password", href: "#password")

          expect(page).to have_field("username", type: "email", with: user.email, disabled: true)
        end
      end

      context "when signed in as a different user than the one that requested the password reset" do
        scenario "needs to sign out before being able to reset the password for the original user" do
          # Original user requests password reset
          request_password_reset

          # Second user attempts to use original user reset password link
          other_user = case user
                       when SubmitUser then create(:submit_user, :with_responsible_person)
                       when SearchUser then create(:poison_centre_user)
                       end

          sign_in(other_user)
          visit edit_user_password_url_with_token
          expect_to_be_on_signed_in_as_another_user_page

          # Second user decides to continue resetting the password for the original user
          click_on "Reset password for #{user.name}"

          # Need to pass 2FA authentication for original user
          expect_to_be_on_secondary_authentication_page
          complete_secondary_authentication_with(otp_code)

          # Finally can change the original user password
          expect_to_be_on_edit_user_password_page

          fill_in "Password", with: "a_new_password"
          click_on "Continue"

          expect_to_be_on_password_changed_page
        end
      end
    end

    context "with an expired token" do
      scenario "does not allow you to reset your password" do
        request_password_reset

        travel_to 66.minutes.from_now do
          visit edit_user_password_url_with_token

          expect(page).to have_css("h1", text: "This link has expired")
          expect(page).to have_link("sign in page", href: "/sign-in")
        end
      end
    end
  end

  describe "for submit" do
    before do
      configure_requests_for_submit_domain
    end

    let(:user) { create(:submit_user) }
    let!(:reset_token)                      { stubbed_devise_generated_token }
    let(:edit_user_password_url_with_token) { "http://#{ENV.fetch('SUBMIT_HOST')}/password/edit?reset_password_token=#{reset_token.first}" }
    let(:expected_text) { "Are you or your organisation a UK Responsible Person?" }

    include_examples "password reset"
  end

  describe "for search" do
    before do
      configure_requests_for_search_domain
    end

    let(:user) { create(:poison_centre_user) }
    let!(:reset_token)                      { stubbed_devise_generated_token }
    let(:edit_user_password_url_with_token) { "http://#{ENV.fetch('SEARCH_HOST')}/password/edit?reset_password_token=#{reset_token.first}" }
    let(:expected_text) { "Search cosmetic products" }

    include_examples "password reset"
  end


  def request_password_reset
    user.update!(reset_password_token: reset_token)

    visit "/sign-in"

    click_link "Forgot your password?"

    perform_enqueued_jobs do
      expect_to_be_on_reset_password_page

      expect(page).to have_css("h1", text: "Reset your password")

      fill_in "Email address", with: user.email
      click_on "Send email"

      expect(delivered_emails.size).to eq 1
      email = delivered_emails.first

      expect(email.recipient).to eq user.email
      expect(email.reference).to eq "Password reset"
      expect(email.template).to eq NotifyMailer::TEMPLATES[:reset_password_instruction]
      expect(email.personalization).to eq(edit_user_password_url_token: edit_user_password_url_with_token, name: user.name)

      expect_to_be_on_check_your_email_page
    end
  end
end
