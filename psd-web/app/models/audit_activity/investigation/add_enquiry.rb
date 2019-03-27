class AuditActivity::Investigation::AddEnquiry < AuditActivity::Investigation::Add
  def self.from(investigation)
    super(investigation, self.build_title(investigation), self.build_body(investigation))
  end

  def self.build_title(investigation)
    "Enquiry logged: #{investigation.title}"
  end

  def self.build_body(investigation)
    body = "**Enquiry details**<br>"
    body += "<br>Attachment: **#{self.sanitize_text investigation.documents.first.filename}**<br>" if investigation.documents.attached?
    body += "<br>#{self.sanitize_text investigation.description}" if investigation.description.present?
    body += self.build_complainant_details(investigation.complainant) if investigation.complainant.present?
    body += self.build_assignee_details(investigation) if investigation.assignee.present?
    body
  end
end
