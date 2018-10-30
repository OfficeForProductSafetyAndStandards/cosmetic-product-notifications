class UpdateDocumentAuditActivity < DocumentAuditActivity
  def self.from(document, investigation, previous_data)
    if document.metadata[:title] != previous_data[:title]
      title = "Updated: #{document.metadata[:title] || "Untitled document"} (was: #{previous_data[:title] || "Untitled document"})"
    elsif document.metadata[:description] != previous_data[:description]
      title = "Updated: Description for #{document.metadata[:title]}"
    end
    activity = self.create(
        description: document.metadata[:description],
        source: UserSource.new(user: current_user),
        investigation: investigation,
        title: title)
    activity.document.attach document.blob
  end

  def subtitle_slug
    "Document details updated"
  end
end
