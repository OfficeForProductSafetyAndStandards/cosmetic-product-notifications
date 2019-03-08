class NotifyMailer < GovukNotifyRails::Mailer
  def send_responsible_person_verification_email(responsible_person_id, email_address, user_name)
    key = EmailVerificationKey.create(
      responsible_person_id: responsible_person_id
)

    set_template('50072d05-d058-4a02-a239-0d73ef7291b2')
    set_reference('Responsible person verification email')

    set_personalisation(
      user_name: user_name,
      verification_link: responsible_person_email_verification_key_url(responsible_person_id, key.key)
    )

    mail(to: email_address)
  end
end
