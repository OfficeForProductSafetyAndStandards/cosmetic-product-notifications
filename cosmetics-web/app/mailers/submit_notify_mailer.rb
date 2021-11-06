class SubmitNotifyMailer < NotifyMailer
  default delivery_method: :submit_govuk_notify

  TEMPLATES =
    # please add email name in Notify as comment
    {
      account_already_exists: "64ab6e58-12e8-4a66-89a0-84a87d49faa9", # Account creation with existing email address
      responsible_person_invitation: "aaa1ae91-c98f-492e-af58-9d44c93fe2f4", # Invitation to join Responsible Person
      responsible_person_invitation_for_existing_user: "3c677e3c-0e49-49f6-b6fa-b0c11595f439", # Invitation to join Responsible Person for existing user
      responsible_person_address_change_for_author: "f56a1045-f6c3-417a-8c08-9c5c6da17c25", # Responsible Person address change - email notification to author
      responsible_person_address_change_for_others: "68d707a6-2636-4313-8735-649e29263f8e", # Responsible Person address change - email notification to others
      reset_password_instruction: "aaa945b4-d848-4b11-b22c-8bbc95d97df4", #  Reset password
      account_locked: "26d6fb70-1c5d-49ff-a3ee-dc30e94a305e", # Unlock account / reset password after too many incorrect password attempts
      verify_new_account: "616e1eb9-4071-4343-8f18-3d2fcd7b9b47", # Verify email address
      verify_new_email: "68edf46c-627d-4609-ae2e-ba9d4b32e3d6", # Confirm new email address
      update_email_notification: "a1f0632a-a687-4911-8d60-526bdd8933a0", # Email address updated on Submit Cosmetic Product Notifications
    }.freeze

  def send_account_already_exists(user)
    set_template(TEMPLATES[:account_already_exists])

    set_reference("Account creation with existing email address")

    set_personalisation(
      name: user.name,
      sign_in_url: new_submit_user_session_url(host: submit_host),
      forgotten_password_url: new_submit_user_password_url(host: submit_host),
    )

    mail(to: user.email)
    Sidekiq.logger.info "Account creation with existing email send"
  end

  def send_responsible_person_invite_email(responsible_person, invited_team_member, inviting_user_name)
    @host = submit_host
    set_reference("Invite user to join responsible person")
    user = SubmitUser.find_by(email: invited_team_member.email_address)
    if user
      set_template(TEMPLATES[:responsible_person_invitation_for_existing_user])
    else
      set_template(TEMPLATES[:responsible_person_invitation])
    end
    set_personalisation(
      responsible_person: responsible_person.name,
      invite_sender: inviting_user_name,
      invitation_url: join_responsible_person_team_members_url(responsible_person.id, invitation_token: invited_team_member.invitation_token),
    )
    mail(to: invited_team_member.email_address)
    Sidekiq.logger.info "Responsible person invite email sent"
  end

  def send_account_confirmation_email(user)
    set_host(user)
    set_template(TEMPLATES[:verify_new_account])
    set_reference("Send confirmation code")

    set_personalisation(
      name: user.name,
      verify_email_url: registration_confirm_submit_user_url(confirmation_token: user.confirmation_token, host: @host),
    )

    mail(to: user.email)
    Sidekiq.logger.info "Confirmation email send"
  end

  def send_responsible_person_address_change_confirmation_email(responsible_person, user, old_rp_address)
    @host = submit_host
    set_template(TEMPLATES[:responsible_person_address_change_for_author])
    set_reference("Send Responsible Person address change confirmation")
    set_personalisation(
      name: user.name,
      name_of_responsible_person: responsible_person.name,
      old_rp_address: old_rp_address,
      new_rp_address: responsible_person.address_lines.join(", "),
    )
    mail(to: user.email)
    Sidekiq.logger.info "Responsible Person address change confirmation email sent"
  end

  def send_responsible_person_address_change_alert_email(responsible_person, user, author_name, old_rp_address)
    @host = submit_host
    set_template(TEMPLATES[:responsible_person_address_change_for_others])
    set_reference("Send Responsible Person address change alert")
    set_personalisation(
      name: user.name,
      name_of_person_who_changed_rp_address: author_name,
      name_of_responsible_person: responsible_person.name,
      old_rp_address: old_rp_address,
      new_rp_address: responsible_person.address_lines.join(", "),
    )
    mail(to: user.email)
    Sidekiq.logger.info "Responsible Person address change alert email sent"
  end
end
