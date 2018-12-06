class AuditActivity::Investigation::Add < AuditActivity::Investigation::Base
  include ActivityAttachable
  with_attachments attachment: "attachment"

  def self.from(investigation)
    activity = super(investigation, self.build_title(investigation), self.build_body(investigation))
    activity.attach_blob investigation.documents.first.blob if investigation.documents.attached?
  end

  def self.build_title(investigation)
    "#{investigation.is_case ? 'Allegation' : 'Question'} logged: #{investigation.title}"
  end

  def self.build_body(investigation)
    body = ""
    body += self.build_allegation_details(investigation) if investigation.is_case
    body += self.build_question_details(investigation) if !investigation.is_case
    body += investigation.description if investigation.description.present?
    body += self.build_reporter_details(investigation.reporter) if investigation.reporter.present?
    body
  end

  def self.build_allegation_details(investigation)
    details =  "**Allegation details**<br>"
    details += "Product type: **#{investigation.product_type}**<br>" if investigation.product_type.present?
    details += "Hazard type: **#{investigation.hazard_type}**<br>" if investigation.hazard_type.present?
    details += "<br>#{investigation.description}" if investigation.description.present?
    details
  end

  def self.build_question_details(investigation)
    details = "**Question details**<br>"
    details += "<br>#{investigation.description}" if investigation.description.present?
    details
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
