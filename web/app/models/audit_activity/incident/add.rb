class AuditActivity::Incident::Add < AuditActivity::Incident::Base
  def self.from(incident, investigation)
    super(incident, investigation)
  end

  def subtitle_slug
    "Incident added"
  end
end
