class SearchNotifyMailer < NotifyMailer
  default delivery_method: :search_govuk_notify

  TEMPLATES =
    # please add email name in Notify as comment
    {
      invitation: "f1e0e917-d2f0-4e50-b1c2-7d52c87520e0", # Invite to join Search Cosmetic Product Notifications
      reset_password_instruction: "aaa945b4-d848-4b11-b22c-8bbc95d97df4", #  Reset password
      account_locked: "26d6fb70-1c5d-49ff-a3ee-dc30e94a305e", # Unlock account / reset password after too many incorrect password attempts
      verify_new_email: "68edf46c-627d-4609-ae2e-ba9d4b32e3d6", # Confirm new email address
      update_email_notification: "a1f0632a-a687-4911-8d60-526bdd8933a0", # Email address updated on Submit Cosmetic Product Notifications
    }.freeze

  def invitation_email(user)
    set_host(user)
    set_template(TEMPLATES[:invitation])

    invitation_url = complete_registration_user_url(user.id, invitation: user.invitation_token, host: @host)

    set_personalisation(invitation_url: invitation_url)
    mail(to: user.email)
  end
end
