class NotifyMailer < GovukNotifyRails::Mailer
  def updated_investigation(investigation_pretty_id, name, email, update_text, subject_text)
    set_template('10a5c3a6-9cc7-4edb-9536-37605e2c15ba')
    set_reference('Case updated')

    set_personalisation(
      name: name,
      investigation_url: investigation_url(pretty_id: investigation_pretty_id),
      update_text: update_text,
      subject_text: subject_text
    )

    mail(to: email)
  end

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
