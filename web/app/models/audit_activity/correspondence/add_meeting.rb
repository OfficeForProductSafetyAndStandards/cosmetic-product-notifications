class AuditActivity::Correspondence::AddMeeting < AuditActivity::Correspondence::Base
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
    body += "Meeting with: **#{correspondence.correspondent_name}**<br>" if correspondence.correspondent_name.present?
    body += "Date sent: **#{correspondence.correspondence_date.strftime('%d/%m/%Y')}**<br>" if correspondence.correspondence_date.present?
    body += "Transcript: #{correspondence.transcript.filename.to_s.gsub('_', '\_')}<br>" if correspondence.transcript.attached?
    body += "Related attachment: #{correspondence.related_attachment.filename.to_s.gsub('_', '\_')}<br>" if correspondence.related_attachment.attached?
    body += "<br>#{correspondence.details}" if correspondence.details.present?
    body
  end
end
