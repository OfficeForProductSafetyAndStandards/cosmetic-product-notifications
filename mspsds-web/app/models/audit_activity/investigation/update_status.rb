class AuditActivity::Investigation::UpdateStatus < AuditActivity::Investigation::Base
  def self.from(investigation)
    title = "#{investigation.case_type.titleize} #{investigation.is_closed? ? 'Closed' : 'Reopened'}"
    super(investigation, title, self.sanitize_text(investigation.status_rationale))
  end

  def email_update_text
    "#{investigation.case_type.titleize} status was #{investigation.is_closed? ? 'closed' : 'reopened'}"
  end

  def users_to_notify
    return super if source == investigation.source && source.present?

    super + [investigation.source&.user]
  end
end
