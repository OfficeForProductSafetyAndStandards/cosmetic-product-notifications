class AuditActivity::Document::Add < AuditActivity::Document
  def self.from(document, investigation)
    title = document.metadata[:title] || "Untitled document"
    super(document, investigation, title)
  end

  def subtitle_slug
    "Document added"
  end
end
