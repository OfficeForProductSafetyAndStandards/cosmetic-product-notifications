class NotifyMailer < GovukNotifyRails::Mailer
  # https://www.notifications.service.gov.uk/services/b1dab0f5-4651-4af8-9f15-fa8143ff338d/templates/50072d05-d058-4a02-a239-0d73ef7291b2
  def send_responsible_person_verification_email(responsible_person, user_name, user_email)
    set_template('50072d05-d058-4a02-a239-0d73ef7291b2')
    set_reference('Responsible person verification email')

    set_personalisation(
      responsible_person_name: responsible_person.name,
      responsible_person_email: responsible_person.email_address,
      user_name: user_name,
      user_email: user_email
    )

    mail(to: responsible_person.email_address)
    p "Responsible person verification email sent to #{responsible_person.email_address}"
  end
end
