class AuditActivity::Document::Update < AuditActivity::Document::Base
  def self.from(document, investigation, previous_data)
    return if self.no_change?(document, previous_data)

    if self.title_changed?(document, previous_data)
      title = "Updated: #{document.metadata[:title] || 'Untitled document'} (was: #{previous_data[:title] || 'Untitled document'})"
    elsif self.description_changed?(document, previous_data)
      title = "Updated: Description for #{document.metadata[:title]}"
    end
    super(document, investigation, title)
  end

  def subtitle_slug
    "#{attachment_type} details updated"
  end

  def self.no_change?(document, previous_data)
    document.metadata[:title] == previous_data[:title] && document.metadata[:description] == previous_data[:description]
  end

  def self.title_changed?(document, previous_data)
    document.metadata[:title] != previous_data[:title]
  end

  def self.description_changed?(document, previous_data)
    document.metadata[:description] != previous_data[:description]
  end

  def email_update_text
    "Document attached to the #{investigation.case_type.titleize} was updated by #{source&.show&.titleize}."
  end
end
