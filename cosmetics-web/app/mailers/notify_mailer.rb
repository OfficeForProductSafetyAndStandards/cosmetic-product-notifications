class NotifyMailer < GovukNotifyRails::Mailer
  TEMPLATES =
    {
      account_locked: "0a78e692-977e-4ca7-94e9-9de64ebd8a5d", # PSD one
      reset_password_instruction: "cea1bb37-1d1c-4965-8999-6008d707b981", # PSD one
      invitation: "7b80a680-f8b3-4032-982d-2a3a662b611a", # PSD one
    }.freeze

  def send_contact_person_verification_email(contact_person_name, contact_person_email, responsible_person_name, user_name)
    set_template("50072d05-d058-4a02-a239-0d73ef7291b2")
    set_reference("Contact person verification email")

    set_personalisation(
      user_name: user_name,
      contact_name: contact_person_name,
      responsible_person: responsible_person_name,
    )

    mail(to: contact_person_email)
    Sidekiq.logger.info "Contact person verification email sent"
  end

  def send_responsible_person_invite_email(responsible_person_id, responsible_person_name, invited_email_address, inviting_user_name)
    set_template("a473bca1-ff6d-4cee-88f6-83a2592727f4")
    set_reference("Invite user to join responsible person")

    set_personalisation(
      responsible_person_name: responsible_person_name,
      inviting_user_name: inviting_user_name,
      invite_url: join_responsible_person_team_members_url(responsible_person_id),
    )

    mail(to: invited_email_address)
    Sidekiq.logger.info "Responsible person invite email sent"
  end

  def send_account_confirmation_email(user)
    set_host(user)
    set_template("82f13866-747c-4a7a-99d5-2ab279a54b55")
    set_reference("Send confirmation code")

    set_personalisation(
      name: user.name,
      verify_email_url: submit_user_confirmation_url(confirmation_token: user.confirmation_token, host: @host),
    )

    mail(to: user.email)
    Sidekiq.logger.info "Confirmation email send"
  end

  def reset_password_instructions(user, token)
    set_host(user)
    set_template(TEMPLATES[:reset_password_instruction])
    set_reference("Password reset")
    reset_url = if user.is_a? SubmitUser
                  edit_submit_user_password_url(reset_password_token: token, host: @host)
                elsif user.is_a? SearchUser
                  edit_search_user_password_url(reset_password_token: token, host: @host)
                end
    set_personalisation(
      name: user.name,
      edit_user_password_url_token: reset_url,
    )

    mail(to: user.email)
  end

  def account_locked(user, tokens)
    set_host(user)
    set_template(TEMPLATES[:account_locked])

    personalization = {
      name: user.name,
      edit_user_password_url_token: edit_submit_user_password_url(reset_password_token: tokens[:reset_password_token], host: @host),
      unlock_user_url_token: submit_user_unlock_url(unlock_token: tokens[:unlock_token], host: @host),
    }
    set_personalisation(personalization)
    mail(to: user.email)
  end

  def invitation_email(user)
    set_host(user)
    set_template(TEMPLATES[:invitation])

    invitation_url = complete_registration_user_url(user.id, invitation: user.invitation_token, host: @host)

    invited_by = "an admin"

    set_personalisation(invitation_url: invitation_url, inviting_team_member_name: invited_by)
    mail(to: user.email)
  end

  def new_email_verification_email(user)
    set_host(user)
    set_template("82f13866-747c-4a7a-99d5-2ab279a54b55") # confirmation code
    set_reference("Send email confirmation code")

    set_personalisation(
      name: user.name,
      verify_email_url: confirm_my_account_email_url(confirmation_token: user.new_email_confirmation_token, host: @host),
    )

    mail(to: user.new_email)
    Sidekiq.logger.info "Confirmation email send"
  end

private

  def set_host(user)
    if user.is_a? SubmitUser
      @host = ENV["SUBMIT_HOST"]
    end
    if user.is_a? SearchUser
      @host = ENV["SEARCH_HOST"]
    end
  end
end
