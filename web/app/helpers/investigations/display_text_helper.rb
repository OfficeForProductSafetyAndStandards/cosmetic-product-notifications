module Investigations::DisplayTextHelper
  def case_question_text(investigation)
    investigation.is_case ? 'case' : 'question'
  end

  def report_question_text(investigation)
    investigation.is_case ? 'report' : 'question'
  end

  def get_displayable_highlights(highlights)
    highlights.map do |highlight|
      {
        label: get_highlight_title(highlight),
        content: get_highlight_content(highlight)
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

  def get_highlight_content(highlight)
    highlighted_texts = highlight[1]
    sanitized_content = sanitize(highlighted_texts.first, tags: %w(em))
    sanitized_content.html_safe # rubocop:disable Rails/OutputSafety
  end
end
