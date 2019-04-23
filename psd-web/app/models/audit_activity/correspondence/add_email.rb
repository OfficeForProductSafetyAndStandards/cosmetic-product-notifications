class AuditActivity::Correspondence::AddEmail < AuditActivity::Correspondence::Base
  belongs_to :correspondence, class_name: "Correspondence::Email"
  include ActivityAttachable
  with_attachments email_file: "email file", email_attachment: "email attachment"

  def self.from(correspondence, investigation)
    activity = super(correspondence, investigation, self.build_body(correspondence))
    activity.attach_blob(correspondence.email_file.blob, :email_file) if correspondence.email_file.attached?
    activity.attach_blob(correspondence.email_attachment.blob, :email_attachment) if correspondence.email_attachment.attached?
  end

  def self.build_body correspondence
    body = ""
    body += self.build_correspondent_details correspondence
    body += "Subject: **#{self.sanitize_text correspondence.email_subject}**<br>" if correspondence.email_subject.present?
    body += "Date sent: **#{correspondence.correspondence_date.strftime('%d/%m/%Y')}**<br>" if correspondence.correspondence_date.present?
    body += self.build_email_file_body correspondence
    body += self.build_attachment_body correspondence
    body += "<br>#{self.sanitize_text correspondence.details}" if correspondence.details.present?
    body
  end

  def self.build_correspondent_details correspondence
    return "" unless correspondence.correspondent_name || correspondence.email_address

    output = ""
    output += "#{Correspondence::Email.email_directions[correspondence.email_direction]}: " if correspondence.email_direction.present?
    output += "**#{self.sanitize_text correspondence.correspondent_name}** " if correspondence.correspondent_name.present?
    output += self.build_email_address correspondence if correspondence.email_address.present?
    output
  end

  def self.build_email_file_body correspondence
    file = correspondence.email_file
    file.attached? ? "Email: #{self.sanitize_text file.filename}<br>" : ""
  end

  def self.build_attachment_body correspondence
    file = correspondence.email_attachment
    file.attached? ? "Attached: #{self.sanitize_text file.filename}<br>" : ""
  end

  def self.build_email_address correspondence
    output = ""
    output += '(' if correspondence.correspondent_name.present?
    output += self.sanitize_text correspondence.email_address
    output += ')' if correspondence.correspondent_name.present?
    output + "<br>"
  end

  def subtitle_slug
    "Email recorded"
  end

  def restricted_title
    "Email added"
  end

  def email_update_text
    "Email details added to the #{investigation.case_type.titleize} by #{source&.show&.titleize}."
  end

  def activity_type
    "email"
  end
end
