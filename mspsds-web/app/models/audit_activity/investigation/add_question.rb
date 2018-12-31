class AuditActivity::Investigation::AddQuestion < AuditActivity::Investigation::Add
  def self.from(investigation)
    super(investigation, self.build_title(investigation), self.build_body(investigation))
  end

  def self.build_title(investigation)
    "Question logged: #{investigation.title}"
  end

  def self.build_body(investigation)
    body = "**Question details**<br>"
    body += "<br>Attachment: **#{investigation.documents.first.escaped_filename}**<br>" if investigation.documents.attached?
    body += "<br>#{self.sanitize_text investigation.description}" if investigation.description.present?
    body += self.build_reporter_details(self.sanitize_object(investigation.reporter)) if investigation.reporter.present?
    body
  end
end
