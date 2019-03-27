class AuditActivity::Document::Destroy < AuditActivity::Document::Base
  def self.from(document, investigation)
    title = "Deleted: #{document.metadata[:title]}"
    super(document, investigation, title)
  end

  def subtitle_slug
    "#{attachment_type} deleted"
  end

  def email_update_text
    "Document attached to the #{investigation.case_type.titleize} was removed by #{source&.show&.titleize}."
  end
end
