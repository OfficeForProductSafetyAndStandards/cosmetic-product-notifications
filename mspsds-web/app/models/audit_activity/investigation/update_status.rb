class AuditActivity::Investigation::UpdateStatus < AuditActivity::Investigation::Base
  def self.from(investigation)
    title = "#{investigation.case_type.titleize} #{investigation.is_closed? ? 'Closed' : 'Reopened'}"
    super(investigation, title, self.sanitize_text(investigation.status_rationale))
  end

  def email_update_text
    "#{email_subject_text} by #{source&.show&.titleize}."
  end

  def email_subject_text
    "#{investigation.case_type.titleize} was #{investigation.is_closed? ? 'closed' : 'reopened'}"
  end

  def users_to_notify
    return super if investigation.source&.is_a? ReportSource
    return super if source&.user == investigation.source&.user && source.present?

    [investigation.source&.user] + super
  end
end
