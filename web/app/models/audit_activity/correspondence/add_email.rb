class AuditActivity::Correspondence::AddEmail < AuditActivity::Correspondence::Base
  def self.from(correspondence, investigation)
    super(correspondence, investigation, self.build_body(correspondence))
  end

  def subtitle_slug
    "Email recorded"
  end

  def self.build_body correspondence
    body = ""
    body += self.build_correspondent_details_body correspondence
    body += "Subject: **#{correspondence.email_subject}**<br>" if correspondence.email_subject.present?
    body += "Date sent: **#{correspondence.correspondence_date}**<br>" if correspondence.correspondence_date.present?
    body += self.build_email_file_body correspondence
    body += self.build_attachment_body correspondence
  end

  def self.build_correspondent_details_body correspondence
    "#{correspondence.email_direction}: **#{correspondence.correspondent_name}** (#{correspondence.email_address})<br>"
  end

  def self.build_email_file_body correspondence
    file = correspondence.documents.find { |attachment| attachment.metadata[:attachment_category] == "email_file"}
    p "======file+============="
    p "======file+============="
    p "======file+============="
    p "======file+============="
    p file
    "Email: [#{file.filename}](#{"www.google.com"})<br>" if file
  end

  def self.build_attachment_body correspondence
    file = correspondence.documents.find { |attachment| attachment.metadata[:attachment_category] == "email_attachment"}
    "Attached: [#{file.filename}](#{"www.google.com"})<br>" if file
  end
end
