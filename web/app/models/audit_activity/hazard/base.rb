class AuditActivity::Hazard::Base < AuditActivity::Base
  include FileConcern
  has_one_attached :risk_assessment

  private_class_method def self.from(hazard, investigation)
    body = self.build_body(hazard)
    activity = self.create(
      body: body,
      source: UserSource.new(user: current_user),
      investigation: investigation,
      title: hazard.hazard_type,
    )
    activity.handle_file_attachment(hazard)
  end

  def self.build_body(hazard)
    body = ""
    body += "#{hazard.description}\n\n" if hazard.description.present?
    body += "Risk level: **#{hazard.risk_level}**<br>" if hazard.risk_level.present?
    body += "Vulnerable group: **#{hazard.affected_parties}**" if hazard.affected_parties.present?
    body
  end

  def handle_file_attachment(hazard)
    return unless hazard.risk_assessment.attached?

    attach_file_to_attachment_slot(hazard.risk_assessment.blob, risk_assessment)
  end
end
