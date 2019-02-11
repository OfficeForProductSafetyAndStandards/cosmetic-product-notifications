class NotifyMailer < GovukNotifyRails::Mailer
  def updated_investigation(investigation_id, name, email, update_text, subject_text)
    set_template('10a5c3a6-9cc7-4edb-9536-37605e2c15ba')
    set_reference('Case updated')

    set_personalisation(
      name: name,
      investigation_url: investigation_url(id: investigation_id),
      update_text: update_text,
      subject_text: subject_text
    )

    mail(to: email)
  end
end
