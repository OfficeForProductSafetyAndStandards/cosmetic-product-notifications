class NotifyMailer < GovukNotifyRails::Mailer
  def send_responsible_person_verification_email(responsible_person_email, user_name, verification_link)
    set_template('50072d05-d058-4a02-a239-0d73ef7291b2')
    set_reference('Responsible person verification email')

    set_personalisation(
      user_name: user_name,
      verification_link: verification_link
    )

    mail(to: responsible_person_email)
  end
end
