class AuditActivity::Investigation::UpdateAssignee < AuditActivity::Investigation::Base
  def self.from(investigation)
    title = investigation.assignee.id.to_s
    super(investigation, title)
  end

  def subtitle_slug
    "Assigned"
  end

  def assignee_id
    # Using alias for accessing parent method causes errors elsewhere :(
    AuditActivity::Investigation::Base.instance_method(:title).bind(self).call
  end

  def title
    "Assigned to #{User.find_by(id: assignee_id)&.display_name}"
  end
end
