class AlertMailer < GovukNotifyRails::Mailer
  def alert(name, email, email_text, subject_text)
    set_template('47fb7df9-2370-4307-9f86-69455597cdc1')
    set_reference('Alert')

    set_personalisation(
        name: name,
        email_text: email_text,
        subject_text: subject_text
    )

    mail(to: email)
  end
end
