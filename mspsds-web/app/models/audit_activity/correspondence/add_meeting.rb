class AuditActivity::Correspondence::AddMeeting < AuditActivity::Correspondence::Base
  belongs_to :correspondence, class_name: "Correspondence::Meeting"
  include ActivityAttachable
  with_attachments transcript: "transcript", related_attachment: "related attachment"

  def self.from(correspondence, investigation)
    activity = super(correspondence, investigation, self.build_body(correspondence))
    activity.attach_blob(correspondence.transcript.blob, :transcript) if correspondence.transcript.attached?
    activity.attach_blob(correspondence.related_attachment.blob, :related_attachment) if correspondence.related_attachment.attached?
  end

  def subtitle_slug
    "Meeting recorded"
  end

  def self.build_body correspondence
    body = ""
    body += "Meeting with: **#{self.sanitize_text correspondence.correspondent_name}**<br>" if correspondence.correspondent_name.present?
    body += "Date: **#{correspondence.correspondence_date.strftime('%d/%m/%Y')}**<br>" if correspondence.correspondence_date.present?
    body += "Transcript: #{self.sanitize_text correspondence.transcript.filename}<br>" if correspondence.transcript.attached?
    body += "Related attachment: #{self.sanitize_text correspondence.related_attachment.filename}<br>" if correspondence.related_attachment.attached?
    body += "<br>#{self.sanitize_text correspondence.details}" if correspondence.details.present?
    body
  end

  def email_update_text
    "Meeting details added to the #{investigation.case_type.titleize} by #{source&.show&.titleize}."
  end
end
