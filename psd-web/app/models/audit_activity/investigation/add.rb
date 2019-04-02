class AuditActivity::Investigation::Add < AuditActivity::Investigation::Base
  include ActivityAttachable
  with_attachments attachment: "attachment"

  private_class_method def self.from(investigation, title, body)
    activity = super(investigation, title, body)
    activity.attach_blob investigation.documents.first.blob if investigation.documents.attached?
  end

  def self.build_complainant_details(complainant)
    details = "<br><br>**Complainant**<br>"
    details += "<br>Name: **#{self.sanitize_text complainant.name}**" if complainant.name.present?
    details += "<br>Type: **#{self.sanitize_text complainant.complainant_type}**" if complainant.complainant_type.present?
    details += "<br>Phone number: **#{self.sanitize_text complainant.phone_number}**" if complainant.phone_number.present?
    details += "<br>Email address: **#{self.sanitize_text complainant.email_address}**" if complainant.email_address.present?
    details += "<br><br>#{self.sanitize_text complainant.other_details}" if complainant.other_details.present?
    details
  end

  def self.build_assignee_details(investigation)
    "<br><br>Assigned to #{investigation.assignee&.display_name}."
  end

  def can_display_all_data?
    return true if investigation.complainant.blank?

    investigation.complainant&.can_be_displayed?
  end

  def restricted_title
    title
  end
end
