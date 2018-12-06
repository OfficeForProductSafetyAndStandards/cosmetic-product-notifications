class AuditActivity::Investigation::Add < AuditActivity::Investigation::Base
  include ActivityAttachable
  with_attachments attachment: "attachment"

  private_class_method def self.from(investigation, title, body)
    activity = super(investigation, title, body)
    activity.attach_blob investigation.documents.first.blob if investigation.documents.attached?
  end

  def self.build_reporter_details(reporter)
    details = "<br>**Reporter**<br>"
    details += "Name: **#{reporter.name}**<br>" if reporter.name.present?
    details += "Type: **#{reporter.reporter_type}**<br>" if reporter.reporter_type.present?
    details += "Phone number: **#{reporter.phone_number}**<br>" if reporter.phone_number.present?
    details += "Email address: **#{reporter.email_address}**<br>" if reporter.email_address.present?
    details += "<br>#{reporter.other_details}" if reporter.other_details.present?
    details
  end
end
