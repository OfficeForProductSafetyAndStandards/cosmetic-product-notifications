class AuditActivity::Document::Destroy < AuditActivity::Document
  def self.from(document, investigation)
    title = "Deleted: #{document.metadata[:title]}"
    super(document, investigation, title)
  end

  def subtitle_slug
    "Document deleted"
  end
end
