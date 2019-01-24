class AuditActivity::Investigation::AddAllegation < AuditActivity::Investigation::Add
  def self.from(investigation)
    super(investigation, self.build_title(investigation), self.build_body(investigation))
  end

  def self.build_title(investigation)
    "Allegation logged: #{investigation.title}"
  end

  def self.build_body(investigation)
    body =  "**Allegation details**<br>"
    body += "<br>Product category: **#{investigation.product_category}**" if investigation.product_category.present?
    body += "<br>Hazard type: **#{investigation.hazard_type}**" if investigation.hazard_type.present?
    body += "<br>Attachment: **#{self.sanitize_text investigation.documents.first.filename}**" if investigation.documents.attached?
    body += "<br><br>#{self.sanitize_text investigation.description}" if investigation.description.present?
    body += self.build_reporter_details(investigation.reporter) if investigation.reporter.present?
    body
  end
end
