class AuditActivity::Document::Add < AuditActivity::Document::Base
  def self.from(document, investigation)
    title = document.metadata[:title] || "Untitled document"
    super(document, investigation, title)
  end

  def subtitle_slug
    "#{attachment_type} added"
  end

  def email_update_text
    "Document was attached to the #{investigation.case_type.titleize} by #{source&.show&.titleize}."
  end
end
