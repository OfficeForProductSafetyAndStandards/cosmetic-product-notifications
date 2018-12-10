class AuditActivity::CorrectiveAction::Add < AuditActivity::CorrectiveAction::Base
  def self.from(corrective_action)
    super(corrective_action)
  end

  def subtitle_slug
    "Corrective action recorded"
  end
end
