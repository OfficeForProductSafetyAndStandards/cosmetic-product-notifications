class AuditActivity::Investigation::UpdateSummary < AuditActivity::Investigation::Base
  def self.from(investigation)
    title = "#{investigation.case_type.titleize} summary updated"
    super(investigation, title, investigation.description)
  end

  def email_update_text
    "#{investigation.case_type.titleize} summary was updated by #{source&.show&.titleize}."
  end
end
