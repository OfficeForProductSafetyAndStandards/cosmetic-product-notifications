class AuditActivity::Incident::Base < AuditActivity::Base
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
    body = ""
    body += "#{incident.description}\n\n" if incident.description.present?
    body += "Occurred: **#{incident.date.strftime('%d/%m/%Y')}**<br>" if incident.date.present?
    body += "Affected party: **#{incident.affected_party}**<br>" if incident.affected_party.present?
    body += "Location: **#{incident.location}**" if incident.location.present?
    body
  end
end
