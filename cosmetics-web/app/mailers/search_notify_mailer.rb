class SearchNotifyMailer < NotifyMailer
  default delivery_method: :search_govuk_notify

  TEMPLATES =
    # please add email name in Notify as comment
    {
      invitation: "afa69f3d-1c7e-4f1f-86a2-4e8ecf7da1dc", # Invite to join Search Cosmetic Product Notifications
      reactivate_account: "969698e7-51cd-4e08-a82e-620090bc11fc", # Reactivate account
      reset_password_instruction: "b40f6179-915a-40a9-94ef-32a0d8d82bba", # Reset password
      reset_account_instruction: "fc3f3475-7c67-47b9-a491-bdf61c59bdaa", # Account reset
      account_locked: "417fd139-8bc8-4c91-bae0-91dedda64c16", # Unlock account / reset password after too many incorrect password attempts
      verify_new_email: "8048cb0e-4e91-4a57-9944-1fbe592df232", # Confirm new email address
      update_email_notification: "f417c719-135f-40c0-9d95-0c0a34c3acf6", # Email address updated on Submit Cosmetic Product Notifications
    }.freeze

  def invitation_email(user)
    set_host(user)
    set_template(TEMPLATES[:invitation])

    invitation_url = complete_registration_user_url(user.id, invitation: user.invitation_token, host: @host)

    set_personalisation(invitation_url:)
    mail(to: user.email)
  end

  def account_reactivated_email(user, token)
    set_host(user)
    set_template(TEMPLATES[:reactivate_account])
    set_reference("Reactivate account")
    reset_url = edit_search_user_password_url(reset_password_token: token, host: @host)
    set_personalisation(
      name: user.name,
      edit_user_password_url_token: reset_url,
    )

    mail(to: user.email)
  end
end
