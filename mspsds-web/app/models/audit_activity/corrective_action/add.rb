class AuditActivity::CorrectiveAction::Add < AuditActivity::CorrectiveAction::Base
  def self.from(corrective_action)
    super(corrective_action)
  end

  def subtitle_slug
    "Corrective action recorded"
  end

  def email_update_text
    "Corrective action was added to the #{investigation.case_type.titleize} by #{source&.show&.titleize}."
  end
end
