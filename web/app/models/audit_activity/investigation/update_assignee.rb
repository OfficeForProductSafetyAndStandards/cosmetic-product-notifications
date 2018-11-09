class AuditActivity::Investigation::UpdateAssignee < AuditActivity::Investigation::Base
  def self.from(investigation)
    title = "Assigned to #{investigation.assignee.full_name}"
    super(investigation, title)
  end

  def subtitle_slug
    "Assigned"
  end
end
