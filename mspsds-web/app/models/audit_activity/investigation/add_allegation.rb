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
    body += "<br>Attachment: **#{investigation.documents.first.escaped_filename}**" if investigation.documents.attached?
    body += "<br><br>#{self.sanitize_text investigation.description}" if investigation.description.present?
    body += self.build_reporter_details(self.sanitize_object(investigation.reporter)) if investigation.reporter.present?
    body
  end
end
