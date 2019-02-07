class AuditActivity::Document::Base < AuditActivity::Base
  include ActivityAttachable
  with_attachments attachment: "document"

  private_class_method def self.from(document, investigation, title)
    activity = self.new(
      body: self.sanitize_text(document.metadata[:description]),
      source: UserSource.new(user: current_user),
      investigation: investigation,
      title: title
    )
    activity.notify_relevant_users
    activity.save
    activity.attach_blob document
  end

  def attachment_type
    attached_image? ? "Image" : "Document"
  end

  def attached_image?
    self.attachment.image?
  end
end
