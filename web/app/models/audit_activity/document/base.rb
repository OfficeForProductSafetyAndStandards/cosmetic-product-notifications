class AuditActivity::Document::Base < AuditActivity::Base
  include ActivityAttachable
  with_attachments attachment: "document"

  private_class_method def self.from(document, investigation, title)
    activity = self.create(
      body: document.metadata[:description],
      source: UserSource.new(user: current_user),
      investigation: investigation,
      title: title
    )
    attach_to_activity(activity, document)
  end
end
