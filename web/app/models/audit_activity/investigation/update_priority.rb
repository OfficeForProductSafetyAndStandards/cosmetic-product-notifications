class AuditActivity::Investigation::UpdatePriority < AuditActivity::Investigation::Base
  def self.from(investigation)
    title = "Priority: #{investigation.priority&.titleize || 'Not set'}"
    super(investigation, title, investigation.priority_rationale)
  end

  def subtitle_slug
    "Set"
  end
end
