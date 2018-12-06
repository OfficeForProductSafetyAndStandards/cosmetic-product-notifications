class AuditActivity::Investigation::AddAllegation < AuditActivity::Investigation::Add
  def self.from(investigation)
    super(investigation, self.build_title(investigation), self.build_body(investigation))
  end

  def self.build_title(investigation)
    "Allegation logged: #{investigation.title}"
  end

  def self.build_body(investigation)
    body =  "**Allegation details**<br>"
    body += "<br>Product type: **#{investigation.product_type}**" if investigation.product_type.present?
    body += "<br>Hazard type: **#{investigation.hazard_type}**" if investigation.hazard_type.present?
    body += "<br>Attachment: **#{investigation.documents.first.filename.to_s.gsub('_', '\_')}**" if investigation.documents.attached?
    body += "<br><br>#{investigation.description}" if investigation.description.present?
    body += self.build_reporter_details(investigation.reporter) if investigation.reporter.present?
    body
  end
end
