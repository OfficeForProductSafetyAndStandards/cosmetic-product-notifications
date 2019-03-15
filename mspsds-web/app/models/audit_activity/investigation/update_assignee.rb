class AuditActivity::Investigation::UpdateAssignee < AuditActivity::Investigation::Base
  def self.from(investigation)
    title = investigation.assignee.id.to_s
    body = investigation.assignee_rationale
    super(investigation, title, body)
  end

  def subtitle_slug
    "Assigned"
  end

  def assignable_id
    # We store assignable_id in title field, this is getting it back
    # Using alias for accessing parent method causes errors elsewhere :(
    AuditActivity::Investigation::Base.instance_method(:title).bind(self).call
  end

  def title
    # We store assignable_id in title field, this is computing title based on that
    "Assigned to #{(User.find_by(id: assignable_id) || Team.find_by(id: assignable_id))&.display_name}"
  end

  def email_update_text
    "#{investigation.case_type.titleize} was assigned to #{investigation.assignee.display_name} by #{source&.show&.titleize}.\n" + assignee_rationale_email_text.to_s
  end

  def assignee_rationale_email_text
    if investigation.assignee_rationale.present?
      "\nComment provided by #{source&.show&.titleize}:
      #{investigation.assignee_rationale}\n"
    end
  end

  def email_subject_text
    "#{investigation.case_type.titleize} was reassigned"
  end

  def users_to_notify
    compute_relevant_entities(model: User, compute_users_from_entity: Proc.new { |user| [user] })
  end

  def teams_to_notify
    compute_relevant_entities(model: Team, compute_users_from_entity: Proc.new { |team| team.users })
  end

  def compute_relevant_entities(model:, compute_users_from_entity:)
    previous_assignee_id = investigation.saved_changes["assignable_id"][0]
    previous_assignee = model.find_by(id: previous_assignee_id)
    new_assignee = investigation.assignee
    assigner = source.user

    old_users = previous_assignee.present? ? compute_users_from_entity.call(previous_assignee) : []
    old_entities = previous_assignee.present? ? [previous_assignee] : []
    new_entities = new_assignee.is_a?(model) ? [new_assignee] : []
    return new_entities if old_users.include? assigner

    (new_entities + old_entities).uniq
  end
end
