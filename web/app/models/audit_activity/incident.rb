class AuditActivity::Incident < AuditActivity
  private_class_method def self.from(incident, investigation)
    body = self.build_body(incident)
    self.create(
      body: body,
      source: UserSource.new(user: current_user),
      investigation: investigation,
      title: incident.incident_type,
    )
  end

  def self.build_body(incident)
    "#{incident.description}<br><br>
    Occurred: **#{incident.date}**<br>
    Affected party: **#{incident.affected_party}**<br>
    Location: **#{incident.location}**"
  end
end
