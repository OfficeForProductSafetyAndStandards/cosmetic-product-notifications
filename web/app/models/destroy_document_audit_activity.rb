class DestroyDocumentAuditActivity < DocumentAuditActivity
  def self.from(document, investigation)
    title = "Deleted: #{document.metadata[:title]}"
    activity = self.create(
        description: document.metadata[:description],
        source: UserSource.new(user: current_user),
        investigation: investigation,
        title: title)
    activity.document.attach document.blob
  end

  def subtitle_slug
    "Document deleted"
  end
end
