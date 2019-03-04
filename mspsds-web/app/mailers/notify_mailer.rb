class NotifyMailer < GovukNotifyRails::Mailer
  def investigation_updated(investigation_pretty_id, name, email, update_text, subject_text)
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

  def investigation_created(investigation_pretty_id, name, email, investigation_title, investigation_type)
    set_template('6da8e1d5-eb4d-4f9a-9c3c-948ef57d6136')
    set_reference('Case created')

    set_personalisation(
      name: name,
      case_title: investigation_title,
      case_type: investigation_type,
      case_id: investigation_pretty_id,
      investigation_url: investigation_url(pretty_id: investigation_pretty_id)
    )

    mail(to: email)
  end
end
