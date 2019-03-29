class AuditActivity::Document::Base < AuditActivity::Base
  include ActivityAttachable
  with_attachments attachment: "document"

  private_class_method def self.from(document, investigation, title)
    activity = self.create(
      body: self.sanitize_text(document.metadata[:description]),
      source: UserSource.new(user: User.current),
      investigation: investigation,
      title: title
    )
    activity.attach_blob document
  end

  def attachment_type
    attached_image? ? "Image" : "Document"
  end

  def attached_image?
    self.attachment.image?
  end

  def sensitive_title; end

  def sensitive?
    attachment_creator = User.find_by(id: attachment.metadata[:created_by])
    return false if UserSource.new(user: attachment_creator).user_has_gdpr_access?

    attachment.metadata[:has_consumer_info]
  end
end
