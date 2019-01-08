module Investigations::DisplayTextHelper
  def case_question_text(investigation)
    investigation.is_case ? 'case' : 'question'
  end

  def report_question_text(investigation)
    investigation.is_case ? 'report' : 'question'
  end

  def image_document_text(document)
    document.image? ? 'image' : 'document'
  end

  def get_displayable_highlights(highlights, investigation)
    highlights.map do |highlight|
      {
        label: get_highlight_title(highlight),
        content: get_highlight_content(highlight, investigation)
      }
    end
  end

  def get_highlight_title(highlight)
    field_name = highlight[0]
    replace_unsightly_field_names(field_name).gsub('.', ', ').humanize
  end

  def replace_unsightly_field_names(field_name)
    pretty_field_names = {
      pretty_id: "Case id",
      "activities.search_index": "Activities, comment"
    }
    pretty_field_names[field_name.to_sym] || field_name
  end

  def get_highlight_content(highlight, investigation)
    return "This record contains sensitive data, contact #{investigation.source&.user&.organisation&.name || investigation.source&.user.full_name} for details" if should_be_hidden(highlight, investigation)
    highlighted_texts = highlight[1]
    sanitized_content = sanitize(highlighted_texts.first, tags: %w(em))
    sanitized_content.html_safe # rubocop:disable Rails/OutputSafety
  end

  def should_be_hidden(highlight, investigation)
    p highlight[0].include? "reporter"
    p !investigation.reporter.can_be_displayed?
    return true if (highlight[0].include? "reporter") && (!investigation.reporter.can_be_displayed?)
    false
  end
end
