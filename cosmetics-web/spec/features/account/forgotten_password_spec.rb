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

        select_secondary_authentication_sms
        expect_to_be_on_secondary_authentication_sms_page

        # User can request the 2FA code again
        click_link "Not received a text message?"

        expect_to_be_on_resend_secondary_authentication_page
        click_button "Resend security code"

        expect_to_be_on_secondary_authentication_sms_page
        complete_secondary_authentication_sms_with(otp_code)

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

          select_secondary_authentication_sms

          expect_to_be_on_secondary_authentication_sms_page
          complete_secondary_authentication_sms_with(otp_code)

          expect_to_be_on_edit_user_password_page

          fill_in "Password", with: "as"
          click_on "Continue"

          expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
          expect(page).to have_link("Password must be at least 8 characters", href: "#password")

          expect(page).to have_field("username", type: "email", with: user.email, disabled: true)
        end

        scenario "when the password is empty it shows an error" do
          request_password_reset

          visit edit_user_password_url_with_token

          select_secondary_authentication_sms

          expect_to_be_on_secondary_authentication_sms_page
          complete_secondary_authentication_sms_with(otp_code)

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
          select_secondary_authentication_sms

          expect_to_be_on_secondary_authentication_sms_page
          complete_secondary_authentication_sms_with(otp_code)

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

    let(:mailer) { SubmitNotifyMailer }

    let(:user) { create(:submit_user) }
    let!(:reset_token)                      { stubbed_devise_generated_token }
    let(:edit_user_password_url_with_token) { "http://#{ENV.fetch('SUBMIT_HOST')}/password/edit?reset_password_token=#{reset_token.first}" }
    let(:expected_text) { "Are you or your organisation a UK Responsible Person?" }

    include_examples "password reset"

    context "when the user hasn't completed their registration" do
      # If the user has confirmed their account but not verified with 2FA, the
      # account may be in 'confirmed' state but still requires verification.
      %i[confirmed_not_verified unconfirmed].each do |status|
        context "when user status is #{status}" do
          let(:user) { create(:submit_user, status) }

          scenario "resends the confirmation email and shows the confirmation page" do
            visit "/sign-in"
            click_link "Forgot your password?"

            expect(page).to have_css("h1", text: "Reset your password")
            fill_in "Email address", with: user.email

            perform_enqueued_jobs do
              click_on "Send email"
            end

            expect(delivered_emails.size).to eq 1
            email = delivered_emails.first

            expect(email.recipient).to eq user.email
            expect(email.reference).to eq "Send confirmation code"
            expect(email.template).to eq mailer::TEMPLATES[:verify_new_account]
            expect(email.personalization).to eq(
              verify_email_url: "http://#{ENV.fetch('SUBMIT_HOST')}/confirm-new-account?confirmation_token=#{user.confirmation_token}",
              name: user.name,
            )
            expect_to_be_on_check_your_email_page

            visit "/confirm-new-account?confirmation_token=#{user.confirmation_token}"
            expect(page).to have_css("h1", text: "Setup your account")
          end
        end
      end
    end

    context "when user was invited to a responsible persons and followed the link but haven't completed their registration" do
      let(:responsible_person) { create(:responsible_person, :with_a_contact_person, name: "Responsible Person") }
      let(:invitation) do
        create(:pending_responsible_person_user, email_address: "inviteduser@example.com", responsible_person: responsible_person)
      end

      scenario "resends the responsible person invitation email and shows the confirmation page" do
        # Invited user visits the link from the RP invitation email
        invitation_path = "/responsible_persons/#{responsible_person.id}/team_members/join?invitation_token=#{invitation.invitation_token}"
        visit invitation_path
        expect(page).to have_current_path("/account-security")
        expect(page).to have_css("h1", text: "Setup your account")
        expect(page).to have_field("Full name")

        # User abandons the registration process
        click_link "Sign out"

        # After a while, user tries to Sign in in the service believing it has an active account on it
        visit "/sign-in"

        # User attempts to recover their password (that they never did set up)
        click_link "Forgot your password?"

        expect(page).to have_css("h1", text: "Reset your password")
        fill_in "Email address", with: "inviteduser@example.com"

        perform_enqueued_jobs do
          click_on "Send email"
        end

        # Instead of receiving a reset password email, user receives the invitation email again
        expect(delivered_emails.size).to eq 1
        email = delivered_emails.first

        expect(email.recipient).to eq "inviteduser@example.com"
        expect(email.reference).to eq "Invite user to join responsible person"
        expect(email.template).to eq mailer::TEMPLATES[:responsible_person_invitation_for_existing_user]
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

  describe "for search" do
    before do
      configure_requests_for_search_domain
    end

    let(:mailer) { SearchNotifyMailer }

    let(:user) { create(:poison_centre_user) }
    let!(:reset_token)                      { stubbed_devise_generated_token }
    let(:edit_user_password_url_with_token) { "http://#{ENV.fetch('SEARCH_HOST')}/password/edit?reset_password_token=#{reset_token.first}" }
    let(:expected_text) { "Search cosmetic products" }

    include_examples "password reset"

    context "when the user hasn't completed its registration" do
      let(:user) { create(:search_user, :registration_incomplete) }

      scenario "resends the invitation email and shows the confirmation page" do
        visit "/sign-in"
        click_link "Forgot your password?"

        expect(page).to have_css("h1", text: "Reset your password")
        fill_in "Email address", with: user.email

        perform_enqueued_jobs do
          click_on "Send email"
        end

        expect(delivered_emails.size).to eq 1
        email = delivered_emails.first
        expect(email.recipient).to eq user.email
        expect(email.template).to eq mailer::TEMPLATES[:invitation]
        expect(email.personalization).to eq(
          invitation_url: "http://#{ENV.fetch('SEARCH_HOST')}/users/#{user.id}/complete-registration?invitation=#{user.invitation_token}",
        )
        expect_to_be_on_check_your_email_page
      end
    end
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
      expect(email.template).to eq mailer::TEMPLATES[:reset_password_instruction]
      expect(email.personalization).to eq(edit_user_password_url_token: edit_user_password_url_with_token, name: user.name)

      expect_to_be_on_check_your_email_page
    end
  end
end
