class AuditActivity::Hazard::Update < AuditActivity::Hazard::Base
  def self.from(hazard, investigation)
    super(hazard, investigation)
  end

  def subtitle_slug
    "Hazard updated"
  end
end
