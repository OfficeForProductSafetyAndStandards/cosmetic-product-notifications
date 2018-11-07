class AuditActivity::Hazard::Base < AuditActivity::Base
  private_class_method def self.from(hazard, investigation)
    body = self.build_body(hazard)
    self.create(
      body: body,
      source: UserSource.new(user: current_user),
      investigation: investigation,
      title: hazard.hazard_type,
    )
  end

  def self.build_body(hazard)
    body = ""
    body += "#{hazard.description}\n\n" if hazard.description.present?
    body += "Risk level: **#{hazard.risk_level}**<br>" if hazard.risk_level.present?
    body += "Vulnerable group: **#{hazard.affected_parties}**" if hazard.affected_parties.present?
    body
  end
end
