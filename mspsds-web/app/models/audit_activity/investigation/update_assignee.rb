class AuditActivity::Investigation::UpdateAssignee < AuditActivity::Investigation::Base
  def self.from(investigation)
    title = investigation.assignee.id.to_s
    super(investigation, title)
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
    "#{investigation.case_type.titleize} was assigned to #{investigation.assignee.display_name} by #{source&.show&.titleize}."
  end

  def email_subject_text
    "#{investigation.case_type.titleize} was reassigned"
  end

  def users_to_notify
    previous_assignee_id = investigation.saved_changes["assignable_id"][0]
    previous_assignee = (User.find_by(id: previous_assignee_id) || Team.find_by(id: previous_assignee_id))
    new_assignee = investigation.assignee

    assigner = source.user
    old_users = []
    old_users = previous_assignee.is_a?(User) ? [previous_assignee] : previous_assignee.users if previous_assignee.present?
    default_users = new_assignee.is_a?(User) ? [new_assignee] : new_assignee.users

    return default_users if previous_assignee.blank? || (old_users.include? assigner)

    (default_users + old_users).uniq
  end
end
