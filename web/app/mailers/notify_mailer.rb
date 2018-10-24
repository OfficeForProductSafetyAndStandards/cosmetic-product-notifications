class NotifyMailer < GovukNotifyRails::Mailer
  def assigned_investigation(investigation, name, email)
    set_template('b8260d95-84f8-4f45-928e-7916d27b5a80')
    set_reference('Investigation assigned')

    set_personalisation(
      name: name,
      investigation_url: investigation_url(investigation)
    )

    mail(to: email)
  end
end
