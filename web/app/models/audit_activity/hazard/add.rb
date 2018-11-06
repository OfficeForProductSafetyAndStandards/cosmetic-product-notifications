class AuditActivity::Hazard::Add < AuditActivity::Hazard::Base
  def self.from(hazard, investigation)
    super(hazard, investigation)
  end

  def subtitle_slug
    "Hazard added"
  end
end
