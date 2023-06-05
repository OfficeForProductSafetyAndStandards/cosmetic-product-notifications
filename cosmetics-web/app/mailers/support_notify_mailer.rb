class SupportNotifyMailer < NotifyMailer
  default delivery_method: :support_govuk_notify

  TEMPLATES =
    # please add email name in Notify as comment
    {
      invitation: "b0239bb8-72b5-4b46-8a18-fd25dce97bdc", # Invitation to use SCPN OSU Support Portal
      reset_password_instruction: "e97d6f60-72fe-4a18-82d9-56a1f90af8d0", # Reset your password on the SCPN OSU Support Portal
      account_locked: "67c4f344-c39f-4850-bb38-78abe195450a", # Unlock account/reset password after too many incorrect password attempts
      verify_new_email: "d0d518db-4638-48d7-b16f-645f7143bf2b", # Confirm new email address
      update_email_notification: "8faea753-e17c-4c62-9b6b-5b68aec1b023", # Update email address — warning to the old email address
    }.freeze

  def invitation_email(user)
    set_host(user)
    set_template(TEMPLATES[:invitation])

    invitation_url = complete_registration_support_user_url(user.id, invitation: user.invitation_token, host: @host)

    set_personalisation(invitation_url:)
    mail(to: user.email)
  end
end
