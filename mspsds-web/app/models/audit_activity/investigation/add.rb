class AuditActivity::Investigation::Add < AuditActivity::Investigation::Base
  include ActivityAttachable
  with_attachments attachment: "attachment"

  private_class_method def self.from(investigation, title, body)
    activity = super(investigation, title, body)
    activity.attach_blob investigation.documents.first.blob if investigation.documents.attached?
  end

  def self.build_complainant_details(complainant)
    details = "<br><br>**Complainant**<br><br>"
    details += "Name: **#{self.sanitize_text complainant.name}**<br>" if complainant.name.present?
    details += "Type: **#{self.sanitize_text complainant.complainant_type}**<br>" if complainant.complainant_type.present?
    details += "Phone number: **#{self.sanitize_text complainant.phone_number}**<br>" if complainant.phone_number.present?
    details += "Email address: **#{self.sanitize_text complainant.email_address}**<br>" if complainant.email_address.present?
    details += "<br>#{self.sanitize_text complainant.other_details}" if complainant.other_details.present?
    details
  end

  def sensitive?
    return false if investigation.complainant.blank?

    !investigation.complainant&.can_be_displayed?
  end
end
