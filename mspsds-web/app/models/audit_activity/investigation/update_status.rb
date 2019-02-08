class AuditActivity::Investigation::UpdateStatus < AuditActivity::Investigation::Base
  def self.from(investigation)
    title = "#{investigation.case_type.titleize} #{investigation.is_closed? ? 'Closed' : 'Reopened'}"
    super(investigation, title, self.sanitize_text(investigation.status_rationale))
  end
end
