class AuditActivity::Document < AuditActivity
  has_one_attached :document

  private_class_method def self.from(document, investigation, title)
    activity = self.create(
      body: document.metadata[:description],
        source: UserSource.new(user: current_user),
        investigation: investigation,
        title: title
    )
    activity.document.attach document.blob
  end

  def attached_document?
    self.document.attached?
  end
end
