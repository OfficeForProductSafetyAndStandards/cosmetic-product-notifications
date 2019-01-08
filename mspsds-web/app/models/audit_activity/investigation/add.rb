class AuditActivity::Investigation::Add < AuditActivity::Investigation::Base
  include ActivityAttachable
  with_attachments attachment: "attachment"

  private_class_method def self.from(investigation, title, body)
    activity = super(investigation, title, body)
    activity.attach_blob investigation.documents.first.blob if investigation.documents.attached?
  end

  def self.build_reporter_details(reporter)
    details = "<br><br>**Reporter**<br><br>"
    details += "Name: **#{self.sanitize_text reporter.name}**<br>" if reporter.name.present?
    details += "Type: **#{self.sanitize_text reporter.reporter_type}**<br>" if reporter.reporter_type.present?
    details += "Phone number: **#{self.sanitize_text reporter.phone_number}**<br>" if reporter.phone_number.present?
    details += "Email address: **#{self.sanitize_text reporter.email_address}**<br>" if reporter.email_address.present?
    details += "<br>#{self.sanitize_text reporter.other_details}" if reporter.other_details.present?
    details
  end

  def sensitive_body?
    !investigation.reporter&.can_be_displayed?
  end
end
