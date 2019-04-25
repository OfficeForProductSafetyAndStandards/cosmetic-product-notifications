class NotifyMailer < GovukNotifyRails::Mailer
  def send_responsible_person_verification_email(responsible_person_id, email_address, contact_person_name, responsible_person_name, user_name)
    key = EmailVerificationKey.create(
      responsible_person_id: responsible_person_id
    )

    set_template('50072d05-d058-4a02-a239-0d73ef7291b2')
    set_reference('Responsible person verification email')

    set_personalisation(
      user_name: user_name,
      verification_link: contact_person_confirmation_url(key.key),
      contact_name: contact_person_name,
      responsible_person: responsible_person_name
    )

    mail(to: email_address)
    Sidekiq.logger.info "Contact person verification email sent"
  end

  def send_responsible_person_invite_email(responsible_person_id, responsible_person_name, invited_email_address, inviting_user_name)
    set_template('a473bca1-ff6d-4cee-88f6-83a2592727f4')
    set_reference('Invite user to join responsible person')

    set_personalisation(
      responsible_person_name: responsible_person_name,
      inviting_user_name: inviting_user_name,
      invite_url: join_responsible_person_team_members_url(responsible_person_id)
    )

    mail(to: invited_email_address)
    Sidekiq.logger.info "Responsible person invite email sent"
  end
end
