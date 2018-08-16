module InvestigationsHelper
  def record_assignment(investigation)
    Activity.create(
        source: UserSource.new(user: current_user),
        investigation: investigation,
        activity_type: ActivityType.find_by_name("assign"),
        notes: "Assigned to #{ investigation.assignee.email }",
    )
  end
end
