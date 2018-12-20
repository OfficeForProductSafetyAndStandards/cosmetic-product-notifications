class NotifyMailer < GovukNotifyRails::Mailer
  def assigned_investigation(investigation_id, name, email)
    set_template('b8260d95-84f8-4f45-928e-7916d27b5a80')
    set_reference('Case assigned')

    set_personalisation(
      name: name,
      investigation_url: investigation_url(id: investigation_id)
    )

    mail(to: email)
  end
end
