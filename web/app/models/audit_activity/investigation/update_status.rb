class AuditActivity::Investigation::UpdateStatus < AuditActivity::Investigation::Base
  def self.from(investigation)
    title = investigation.is_closed? ? "Case Closed" : "Case Reopened"
    super(investigation, title, investigation.status_rationale)
  end
end
