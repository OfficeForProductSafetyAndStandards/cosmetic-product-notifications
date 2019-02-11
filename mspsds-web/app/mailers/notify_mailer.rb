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

  def assigned_investigation_to_team(investigation_id, user_name, email, team_name)
    set_template('32343175-0057-48d8-b954-f05d175d2c2a')
    set_reference('Case assigned')

    set_personalisation(
      name: user_name,
      team_name: team_name,
      investigation_url: investigation_url(id: investigation_id)
    )

    mail(to: email)
  end

  def updated_investigation(investigation_id, name, email, update_text)
    set_template('10a5c3a6-9cc7-4edb-9536-37605e2c15ba')
    set_reference('Case updated')

    set_personalisation(
      name: name,
      investigation_url: investigation_url(id: investigation_id),
      update_text: update_text
    )

    mail(to: email)
  end
end
