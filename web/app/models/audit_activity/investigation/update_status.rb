class AuditActivity::Investigation::UpdateStatus < AuditActivity::Investigation::Base
  def self.from(investigation)
    title = "#{investigation.is_case ? 'Case' : 'Question'} #{investigation.is_closed? ? 'Closed' : 'Reopened'}"
    super(investigation, title, investigation.status_rationale)
  end
end
