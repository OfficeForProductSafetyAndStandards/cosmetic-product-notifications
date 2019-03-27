module InvestigationTestHelper
  def set_investigation_source!(investigation, user)
    investigation.source.update user_id: user.id
  end

  def set_investigation_assignee!(investigation, assignee, assignable_type = "User")
    investigation.update_columns(assignable_id: assignee.id, assignable_type: assignable_type)
  end
end
