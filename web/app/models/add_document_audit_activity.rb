class AddDocumentAuditActivity < DocumentAuditActivity
  def self.from(document, investigation)
    title = document.metadata[:title] || "Untitled document"
    activity = self.create(
        description: document.metadata[:description],
        source: UserSource.new(user: current_user),
        investigation: investigation,
        title: title)
    activity.document.attach document.blob
  end

  def subtitle_slug
    "Document added"
  end
end
