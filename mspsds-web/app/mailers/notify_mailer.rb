class NotifyMailer < GovukNotifyRails::Mailer
  TEMPLATES =
    {
        investigation_updated: '10a5c3a6-9cc7-4edb-9536-37605e2c15ba',
        investigation_created: '6da8e1d5-eb4d-4f9a-9c3c-948ef57d613',
        alert: '47fb7df9-2370-4307-9f86-69455597cdc1'
    }.freeze

  def investigation_updated(investigation_pretty_id, name, email, update_text, subject_text)
    set_template(TEMPLATES[:investigation_updated])
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
    set_template(TEMPLATES[:alert])
    set_reference('Alert')

    set_personalisation(
      name: name,
      email_text: email_text,
      subject_text: subject_text
    )

    mail(to: email)
  end

  def investigation_created(investigation_pretty_id, name, email, investigation_title, investigation_type)
    set_template(TEMPLATES[:investigation_created])
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

  def user_added_to_team(name:, email:, team_id:, team_name:)
    # TODO MSPSDS-1407 DO THIS
    mail(to: email)
  end
end
